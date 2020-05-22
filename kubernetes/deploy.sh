#!/usr/bin/env bash
# Script intended for deploying from local machines.
set -o errexit
set -o nounset
set -o pipefail

GIT_URL="https://github.com"
NAMESPACE="product"
REGION="eu-west-1"
REPO_NAME="wt-plat-euwest1-container-registry-product-expiry-manager"
REPO_URI="747772944961.dkr.ecr.eu-west-1.amazonaws.com/$REPO_NAME"
WEBUILD_URL="${WEBUILD_URL:-https://webuild.wetransfer.net}"

MAX_WAIT_TIME_SECS=$((10 * 60)) # 10 minutes
BUILD_FAILED=11 # arbitrary failure code for exception handling

cwd=$(dirname "$0")

usage() {
    cat << EOF >&2

Usage: $(basename "$0") [options] <environment>

Use this script to deploy service to kubernetes cluster(s)

Options:

    -b|--build-arg              Build arg to be passed to `docker build` (accepts multiple args)
    -c|--context,               Kubernetes context name, used as a target for a service deployment. If not set, tool will fallback to <environment> ARG value
    -d|--deploy-only            Skip build step, deploy directly.
    -f|--docker-file <file>,    Dockerfile to use when building. Supports
                                multi-dockerfiles that are comma-separated and
                                refer to paths relative to the root of the
                                GitHub repository. For example, --docker-file
                                Dockerfile,api/Dockerfile.
    -g|--git-ref <ref>,         Git reference (commit, tag) to be checked out for build and deploy.
    -h|--help,                  Display usage.
    -i|--image-only,            Builds docker image and pushes it to ECR repository without deploying service to kubernetes
    -l|--local,                 Build docker image locally, instead of using webuild.
    -p|--profile,               Profile, which is assumed during aws session. Default: wetransfer-plat-product-expiry-manager
    -r|--region,                Region of the cluster that we will deploy

Arguments:

    environment         The name of environment, used during kubernetes resource deloyment. Supported values: dev|stag|prod

EOF
}

# check_uncommited validates that user commited his changes prior to service deployments/docker build
check_uncommited(){
  # Bail out if there are uncommitted changes:
  if [[ $(git diff --stat) == '' ]]; then
    echo "Git repo is clean, ready to go."
    # No changes
  else
    # Changes
    echo "$0: You have uncommitted git changes; resolve this before deploying."
    exit 2
  fi
}

# get_contexts returns currently locally configured Kuberentes context(s)
get_contexts(){
  kubectl config get-contexts -o=name
}

# check_environment validates if user provided environemnt value is supported
check_environment(){
  local environment="$1"

  if [[ "$environment" == "dev" ]] || [[ "$environment" == "stag" ]] || [[ "$environment" == "prod" ]]; then
    return
  else
    echo 'Environment should be one of dev, stag, or prod. Aborting...'
    usage
    exit 1
  fi
}

# check_context validates that provided context is configured on user machine
check_context(){
  local ctx="$1"
  local ctxs=($(get_contexts))

  # Loop through all available contexts in order to validate if context is supported
  for i in "${ctxs[@]}"; do
    if [[ "$i" == "$ctx"* ]]; then
      return
    fi
  done

  # If context is not configured, abort the run and inform the end user
  echo "Context: $ctx is not configured in local kubeconfig. Here are supported contexts (configured locally): "
  get_contexts
  echo "Aborting..."
  exit 1
}

build_images() {
    local git_ref="${1:?git_ref is required by build_images}"
    local profile="${2:?profile is required by build_images}"
    local dockerfile="${3:-Dockerfile}"
    local build_args="${4}" # comma-separated build-args

    # Login to ECR repository
    docker_login "$profile"

    local build_options
    if [ -n "$build_args" ]; then
      IFS="," # split incoming comma-separated list of build args
      for a in $build_args; do
          build_options="$build_options --build-arg $a"
      done
      IFS=" "
    fi

    # Set field separator to comma so that dockerfile arg can be split by commas
    # and iterated over below.
    IFS=","

    # shellcheck disable=2154
    for f in $dockerfile; do
        if [ ! -e "$f" ]; then
            echo "error: Dockerfile $f does not exist" >&2
            exit 1
        fi

        local tag=""
        if [ "$f" == "Dockerfile" ]; then
            tag="$git_ref"
        else
            tag=$(mk_dockerfile_tag "$f" "$git_ref")
        fi

        # shellcheck disable=2086
        docker_cmd build $build_options -f "$f" -t "$REPO_URI":"$tag" .
        docker_cmd push "$REPO_URI":"$tag"
    done

    # Reset field separator.
    IFS=" "
}

mk_dockerfile_tag() {
    local dockerfile="${1:?dockerfile is required by mk_dockerfile_tag}"
    local git_ref="${2:?git_ref is required by git_ref}"

    # Remove non-alphanumerics and lowercase.
    local sanitized
    sanitized=$(echo "$dockerfile" | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]')

    echo "$git_ref-$sanitized"
}

# Run a docker command that is compatible across platforms. Linux requires sudo.
docker_cmd() {
    case "$(uname -s)" in
        Darwin)
            docker $@
            ;;
        Linux)
            sudo docker $@
            ;;
        *)
            docker $@
            ;;
    esac
}

# Run the docker login command such that it is compatible across platforms.
# Linux requires sudo.
docker_login() {
    local profile="${1:?profile is required by docker_login}"

    case "$(uname -s)" in
        Darwin)
            # shellcheck disable=2091
            $(aws --profile "$profile" ecr get-login --no-include-email --region "$REGION" --registry-ids 747772944961)
            ;;
        Linux)
            # shellcheck disable=2046
            sudo $(aws --profile "$profile" ecr get-login --no-include-email --region "$REGION" --registry-ids 747772944961)
            ;;
        *)
            # shellcheck disable=2091
            $(aws --profile "$profile" ecr get-login --no-include-email --region "$REGION" --registry-ids 747772944961)
            ;;
    esac
}

# Notify slack that things are about to be deployed if we are locally,
# if we run this from travis we already send notification on the start of the job.
send_slack_notification(){
  local short_current_commit="$1"
  local environment="$2"
  local namespace="$3"
  local region="$4"

  # TRAVIS variable is always set to true if this runs from a travis environment.
  if [ -z "${TRAVIS:=}" ]; then
    curl -X POST -H 'Content-type: application/json' --data "{'text':':alarm_clock: :rocket: *$(whoami)* is deploying product-expiry-manager version $short_current_commit to $environment in $region.\nSee https://github.com/WeTransfer/product-expiry-manager/commit/$short_current_commit for more information.'}" https://hooks.slack.com/services/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
  fi
}

# deploy used to deploy kubernetes resources to kubernetes cluster/namespace of your choosing
deploy(){
  local environment="$1"
  local ctx="$2"
  local namespace="$3"
  local current_commit="$4"
  local short_current_commit="$5"
  local region="$6"

  send_slack_notification "$short_current_commit" "$environment" "$namespace" "$region"

  # Insert the desired version in the configuration for the desired env and send it to the cluster

  # In our single-region structure we don't have a region directory, so in order for the script to work for single-region even if we specify
  # the region flag we have to check if this path exist. If it doesn't we fall back to a path that doesn't encode the region in it.
  local kustomize_dir
  if [ -d "$cwd/$region/overlays/$environment" ];then
      kustomize_dir="$cwd/$region/overlays/$environment"
  else
      kustomize_dir="$cwd/overlays/$environment"
  fi
  kubectl kustomize "$kustomize_dir" | sed -e "s/__IMAGE_VERSION__/$current_commit/g" | kubectl --context="$ctx" apply -f -
}

# tag_image adds an additional tag to the configured docker image
tag_image(){
  local environment="$1"
  local current_commit="$2"
  local release_tag="$environment-$RANDOM"

  # As we retag already pushed image in order to mark which environment and when it was deployed we need to perform following actions:
  # 1. Check if image exist locally -> if yes, tag it and update remote image by pushing it back to ECR
  # 2. If no -> pull image from ECR, tag it and update remote image by pushing it back to ECR
  if [[ "$(docker_cmd images -q $REPO_URI:$current_commit 2> /dev/null)" == "" ]]; then
    docker_cmd pull "$REPO_URI":"$current_commit"
  fi

  # Tag Docker image as released
  docker_cmd tag "$REPO_URI":"$current_commit" "$REPO_URI":"$release_tag"
  docker_cmd push "$REPO_URI":"$release_tag"
}

check_region() {
    local region="${1:?region is required by check_region}"

    if [ "$region" != "eu-west-1" ] && [ "$region" != "us-east-1" ]; then
        die "Region must be one of eu-west-1 or us-east-1. See -h for usage."
    fi
}

# get_repo_url takes the "origin" remote reference for the repo
# returns the https version
get_repo_https_url() {
  local remote
  remote=$(git remote -v | grep origin | grep fetch)
  remote="${remote##*github.com}" # trim prefix
  remote="${remote:1}"            # remove character following github.com (: or /)
  remote="${remote%%.git*}"       # trim suffix
  remote="${remote%% \(*}"        # trim (fetch) suffix
  echo "$GIT_URL/$remote"
}

webuild_image() {
    local git_ref=$1
    local git_remote=$2
    local basic_auth="${3:?basic_auth is required by webuild_image}"
    local env=$4
    local dockerfile="${5:-Dockerfile}"
    local build_args="${6}"

    local json_build_args="[]"
    if [ -n "$build_args" ]; then
        json_build_args="["
        IFS=","
        for b in $build_args; do
            json_build_args+="\"$b\","
        done
        IFS=" "
        json_build_args="${json_build_args%?}]" # remove trailing comma, add closing bracket
    fi

    # Set field separator to comma so that dockerfile arg can be split by commas
    # and iterated over below.
    IFS=","

    # shellcheck disable=2154
    for f in $dockerfile; do
        if [ ! -e "$f" ]; then
            echo "error: Dockerfile $f does not exist" >&2
            exit 1
        fi

        local payload="{
            \"buildArgs\": $json_build_args,
            \"dockerfile\": \"$f\",
            \"dockerTags\": [\"$env-$RANDOM\"],
            \"gitURI\":\"$git_remote\",
            \"gitCommit\":\"$git_ref\",
            \"service\":\"product-expiry-manager\"
        }"

        local build_res
        build_res=$(curl -s -H "Authorization: basic $basic_auth" "$WEBUILD_URL/build" -d "$payload")

        local build_id
        build_id=$(echo "$build_res" | jq -r ".buildName")

        # Tail logs until container exits.
        tail_logs "$build_id"

        wait_for_successful_webuild "$build_id"
    done

    # Reset field separator.
    IFS=" "
}

# Gets pod status using kubectl.
get_pod_status() {
    local context="${1:?context is required by get_pod_status}"
    local pod_name="${2:?pod_name is required by get_pod_status}"

    kubectl --context "$context" -n webuild get pods \
        --field-selector metadata.name="$pod_name" \
        --output jsonpath="{.items[*].status.phase}"
}

# Resolves the kubcetl context to use when getting webuild pod status or tailing
# webuild logs by using the webuild URL supplied as an environment variable.
resolve_webuild_context() {
    # This assumes an engineer's contexts' have the standard names generated by
    # the kubeconfig/generate.sh script in the platform-kubernetes repo.
    if [[ "$WEBUILD_URL" == *wetransferalpha* ]]; then
        echo "dev"
    elif [[ "$WEBUILD_URL" == *wetransferbeta* ]]; then
        echo "stag"
    else
        echo "prod"
    fi
}

# Tails the logs of a webuild container.
tail_logs() {
  local pod_name="${1:?pod_name is required by tail_logs}"

  local context
  context=$(resolve_webuild_context)

  # Check that prod context exists. If not, then we cannot tail webuild logs.
  if ! kubectl config get-contexts -o name | grep -E "^$context$"; then
      echo "$context context does not exist. Generate the context by following this guide: https://www.notion.so/wetransfer/How-to-Generate-a-Kubeconfig-49b6da77a1554952bb0afd92210c88b1. Then try again." >&2
      exit 1
  fi

  local max_wait_time=120
  local sleep_time=2

  local start_time
  start_time=$(date +%s)

  # A new pod is in the PodInitializing state briefly upon startup. In this
  # state logs cannot be tailed. Wait until the pod exits the state before we
  # attempt to tail the logs.
  local current_status
  current_status=$(get_pod_status "$context" "$pod_name")
  while [ "$current_status" == "Pending" ]; do
      echo "Waiting for $pod_name pod to start. Trying again in ${sleep_time}s." >&2
      sleep "$sleep_time"

      local current_time
      current_time=$(date +%s)
      if [[ $(( current_time - start_time )) -ge "$max_wait_time" ]]; then
          echo "error: exceeded max wait time for pod to start." >&2
          exit 1
      fi

      current_status=$(get_pod_status "$context" "$pod_name")
  done

  # Follow the container's logs for as long as the container is alive.
  kubectl --context "$context" logs -n webuild "$build_id" -f 
}

get_successful_build() {
    local build_id=$1
    local basic_auth="${2:?basic_auth is required by get_successful_build}"

    res=$(curl -s -H "Authorization: basic $basic_auth" "$WEBUILD_URL/builds/$build_id")
    pod_status="$(echo "$res" | jq -r '.scheduledPod.phase')"

    echo "$(date "+%Y-%m-%dT%H:%M:%S%z") Build: $pod_status" >&2
    [ "$pod_status" = "Failed" ] && echo "$BUILD_FAILED" && return $BUILD_FAILED # build will never reach success
    [ "$pod_status" != "Succeeded" ] && return 1 # still waiting for success
    return 0 # success
}

wait_for_successful_webuild() {
    local build_id=$1
    local basic_auth="${basic_auth:?basic_auth is required by wait_for_successful_webuild}"
    local wait_seconds=5

    local start_time
    start_time=$(date +%s)
    while ! res=$(get_successful_build "$build_id" "$basic_auth"); do
        if [ "$res" = $BUILD_FAILED ]; then
            echo "$(date "+%Y-%m-%dT%H:%M:%S%z") Build failed. Exiting..." >&2
            exit 1
        fi

        echo "$(date "+%Y-%m-%dT%H:%M:%S%z") Still waiting for webuild to finish. Trying again in $wait_seconds s..." >&2
        sleep $wait_seconds

        local now
        now=$(date +%s)

        local time_diff=$((now - start_time))
        if [ "$time_diff" -ge "$MAX_WAIT_TIME_SECS" ]; then
            echo "$(date "+%Y-%m-%dT%H:%M:%S%z") Build took too long. Exiting after $(( MAX_WAIT_TIME_SECS / 60 )) minutes..." >&2
            exit 1
        fi
    done
}

main(){
  # local vars
  local current_commit=$(git rev-parse HEAD)
  local git_remote=$(get_repo_https_url)
  local git_ref=""
  local image_only=0
  local deploy_only=0
  local local_docker_build=0
  local profile=wetransfer-plat-product-expiry-manager
  local region="eu-west-1"
  local dockerfile=""
  local build_args=""

  # Check for user input
  while [ "$#" -gt 0 ]; do
        case "$1" in
          -h|--help)
            usage
            exit
            ;;

          -b|--build-arg)
            build_args+="${2:?Missing build-arg parameter},"
            shift 2
            ;;

          -c|--context)
            shift
            local ctx="$1"
            shift
            ;;

          -d|--deploy-only)
            deploy_only=1
            shift
            ;;

          -f|--docker-file)
            dockerfile="$2"
            shift 2
            ;;
            
          -g|--git-ref)
            shift
            git_ref="${1:?empty git-ref argument}"
            shift
            ;;

          -i|--image-only)
            image_only=1
            shift
            ;;

          -p|--profile)
            shift
            profile="$1"
            shift
            ;;

          -r|--region)
            shift
            region="$1"
            shift
            ;;

          -l|--local)
            local_docker_build=1
            shift
            ;;

          *)
            # Print usage and exit if no arguments are provided.
            if [ "$#" -eq 0 ]; then
              usage
              exit 1
            fi

            local environment="${1:?is required, to see usage run \"$(basename "$0") -h\"}"
            shift
            ;;
        esac
  done

  if [ $image_only -eq 1 ] && [ $deploy_only -eq 1 ]; then
    echo "error: image-only and deploy-only arguments are mutually exclusive"
    exit 1
  fi

  # Default to current commit if no git-ref provided
  git_ref="${git_ref:-$current_commit}"

  # Run validation
  check_region "$region"
  check_uncommited
  check_environment "$environment"
  check_context "${ctx:-$environment}"

  # "Fix" build args
  build_args="${build_args%?}" # remove trailing comma :face_palm:

  # Prior to deploying service(s) to kubernetes, build latest image
  if [ $deploy_only -eq 0 ]; then
    if [ $local_docker_build -eq 1 ]; then
      build_images "$git_ref" "$profile" "$dockerfile" "$build_args"
    else
      local basic_auth="${WEBUILD_BASIC_AUTH:?WEBUILD_BASIC_AUTH is required}"
      webuild_image "$git_ref" "$git_remote" "$basic_auth" "$environment" "$dockerfile" "$build_args"
    fi
  fi

  if [ $image_only -eq 0 ]; then
    local short_git_ref=${git_ref:0:8}
    # Deploy to kubernetes
    deploy "$environment" "${ctx:-$environment}" "$NAMESPACE" "$git_ref" "$short_git_ref" "$region"

    if [ $local_docker_build -eq 1 ]; then
      # Run additional tagging logic based on the kubernetes context
      tag_image "$environment" "$git_ref"
    fi
  fi
}

main "$@"
