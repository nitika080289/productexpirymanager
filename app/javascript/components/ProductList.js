import React from "react"
import PropTypes from "prop-types"
import './ProductList.css'
class ProductList extends React.Component {
  render () {
    var products = this.props.products.map((product) => {
      return (
          <tr id={product.id} key={product.id}>
              <td>{product.name}</td>
              <td>{product.expiry_date}</td>
              <td>{product.quantity}</td>
              <td><button onClick={()=> this.props.handleDelete(product.id)}>Delete</button></td>
          </tr>
      )
    });
    return(
        <div id='product_table'>
            <table>
                <thead>
                <tr>
                    <th>Product Name</th>
                    <th>Expiry Date</th>
                    <th>Quantity</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
            {products}
                </tbody>
            </table>
        </div>
    )
  }
}

export default ProductList
