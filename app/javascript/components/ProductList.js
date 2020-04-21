import React from "react"
import PropTypes from "prop-types"
import './ProductList.css'
class ProductList extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            products: []
        };
    }
  render () {
    var products = this.state.products.map((product) => {
      return (
          <tr id={product.id} key={product.id}>
              <td>{product.name}</td>
              <td>{product.expiry_date}</td>
              <td>{product.quantity}</td>
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
                </tr>
                </thead>
                <tbody>
            {products}
                </tbody>
            </table>
        </div>
    )
  }
  componentDidMount () {
      console.log("Component mounted successfully");
      fetch('/products.json').then((response)=>{return response.json()})
          .then((data) => {this.setState({products: data})})

  }
}

export default ProductList
