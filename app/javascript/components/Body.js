import React from "react"
import ProductList from "./ProductList";
import AddProduct from "./AddProduct";
import * as moment from "moment"

class Body extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            products: []
        };
        this.handleSubmit = this.handleSubmit.bind(this)
        this.addNewProduct = this.addNewProduct.bind(this)
        this.handleDelete = this.handleDelete.bind(this)
    }
    handleSubmit(name, expiry_date, quantity) {
        var expiry_date_formatted = moment(expiry_date).format('YYYY-MM-DD')
        var body = JSON.stringify({product: {name: name, expiry_date: expiry_date_formatted, quantity: quantity}})
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
    handleDelete(id){
        fetch('/products/'+id,
            {
                method: 'DELETE',
                headers: {
                    'Content-Type': 'application/json'
                }
            }).then((response) => {
               this.deleteProduct(id)
        })
    }
    addNewProduct(product) {
        this.setState({
            products: this.state.products.concat(product)
        })
    }
    deleteProduct(id){
        var newProductList = this.state.products.filter((product) => product.id !== id)
        this.setState({
            products: newProductList
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
                <br></br>
                <ProductList products={this.state.products} handleDelete = {this.handleDelete} />
            </div>
        )
    }
}
export default Body
