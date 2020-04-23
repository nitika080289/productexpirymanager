import React from "react"
import ProductList from "./ProductList";
import AddProduct from "./AddProduct";

class Body extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            products: []
        };
        this.handleSubmit = this.handleSubmit.bind(this)
        this.addNewProduct = this.addNewProduct.bind(this)
    }
    handleSubmit(name, expiry_date, quantity) {
        var body = JSON.stringify({product: {name: name, expiry_date: expiry_date, quantity: quantity}})
        var token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        fetch('/products', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': token
            },
            body: body
        }).then((response) => {
            return response.json()
        })
            .then((product) => {
                this.addNewProduct(product)
            })

    }
    addNewProduct(product) {
        this.setState({
            products: this.state.products.concat(product)
        })
    }
    componentDidMount(){
        fetch('/products.json')
            .then((response) => {return response.json()})
            .then((data) => {this.setState({ products: data }) });
    }
    render(){
        return(
            <div>
                <AddProduct handleSubmit={this.handleSubmit}/>
                <ProductList products={this.state.products} />
            </div>
        )
    }
}
export default Body
