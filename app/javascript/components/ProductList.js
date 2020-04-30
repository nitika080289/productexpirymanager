import React from "react"
import * as moment from "moment"
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTrash } from '@fortawesome/free-solid-svg-icons';
import './ProductList.css'
class ProductList extends React.Component {
  render () {
    var products = this.props.products.map((product) => {
      return (
          <tr id={product.id} key={product.id}>
              <td>{product.name}</td>
              <td>{product.expiry_date}</td>
              <td>{product.quantity}</td>
              <td><button className="btn" onClick={()=> this.props.handleDelete(product.id)}>
                  <FontAwesomeIcon icon={faTrash}></FontAwesomeIcon></button></td>
              <td><span className={this.getSpanClassBasedOnDate(product.expiry_date)}></span></td>
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
                    <th>Delete</th>
                    <th>Status</th>
                </tr>
                </thead>
                <tbody>
            {products}
                </tbody>
            </table>
        </div>
    )
  }
    getSpanClassBasedOnDate(expiry_date){
        var currentDate = moment(new Date()).format('YYYY-MM-DD')
        var expiryDate = moment(expiry_date)
        var diffDays = expiryDate.diff(currentDate, 'days')
        let spanclassName = ''
      if(diffDays < 0)
          spanclassName = 'red_dot'
        else if(diffDays > 5)
            spanclassName = 'green_dot'
        else
            spanclassName = 'yellow_dot'
        return spanclassName
    }
}

export default ProductList
