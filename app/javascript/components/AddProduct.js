import React from "react"
import PropTypes from "prop-types"
import './ProductList.css'
class AddProduct extends React.Component {
    render() {
        let formFields = {}
        return (
            <form onSubmit= {event => {this.props.handleSubmit(formFields.name.value,
                formFields.expiry_date.value,formFields.quantity.value);
                event.target.reset;}}>
                <h3>Add a product</h3>
                <input ref={input => formFields.name = input} placeholder='Product Name'/>
                <input ref={input => formFields.expiry_date = input} placeholder='Expiry Date'/>
                <input ref={input => formFields.quantity = input} placeholder='Quantity'/>
                <button>Submit</button>
            </form>
        )
    }
}
export default AddProduct
