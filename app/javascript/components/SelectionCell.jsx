import React from 'react'
import Select from 'react-select'
import 'react-select/dist/react-select.css'

export default class SelectionCell extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      selectValue: this.props.value
    }
    this.onChange = this.onChange.bind(this)
  }

  onChange (val) {
    this.setState({selectValue: val}, () =>
      this.props.onChange(val)
    )
  }

  componentWillReceiveProps(nextProps) {
    this.setState({selectValue: nextProps.value})
  }

  render () {
    const id = this.props.id
    const name = this.props.name
    const value = this.state.selectValue
    const options = this.props.options

    return (
      <Select id={id} name={name} value={value}
        options={options} onChange={this.onChange}
        clearable simpleValue />
    )
  }
}
