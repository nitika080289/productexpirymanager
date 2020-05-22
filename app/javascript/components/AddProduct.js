import React from "react"
import './ProductList.css'
class AddProduct extends React.Component {
    render() {
        let formFields = {}
        return (
            <form onSubmit= {event => {this.props.handleSubmit(formFields.name.value,
                formFields.expiry_date.value,formFields.quantity.value);
                event.target.reset;}}>
                <h3>Add a product</h3>
                <label htmlFor="Name">Product Name: </label>
                <input ref={input => formFields.name = input}/>
                <label htmlFor="expiryDate">ExpiryDate: </label>
                <input type="date" ref={input => formFields.expiry_date = input}/>
                <label htmlFor="Quantity">Quantity: </label>
                <input ref={input => formFields.quantity = input}/>
                <button className="button">Add</button>
            </form>
        )
    }
}
export default AddProduct
