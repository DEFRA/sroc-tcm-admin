import React from 'react'
import TransactionTableHeader from './TransactionTableHeader'
import TransactionTableRow from './TransactionTableRow'
import ExclusionReasonDialog from './ExclusionReasonDialog'

export default class TransactionTable extends React.Component {
  constructor (props) {
    super(props)

    this.state = {
      exclusionDialogOpen: false
    }

    this.showExclusionDialog = this.showExclusionDialog.bind(this)
    this.onCancelExclusionDialog = this.onCancelExclusionDialog.bind(this)
    this.onSaveExclusionReason = this.onSaveExclusionReason.bind(this)
  }

  showExclusionDialog (saveCallback, cancelCallback) {
    this.setState({
      exclusionDialogOpen: true,
      saveCallback: saveCallback,
      cancelCallback: cancelCallback
    })
  }

  onCancelExclusionDialog () {
    const cancelFn = this.state.cancelCallback
    if (cancelFn) {
      cancelFn()
    }
    this.setState({
      exclusionDialogOpen: false,
      saveCallback: null,
      cancelCallback: null
    })
  }

  onSaveExclusionReason(reason) {
    const saveFn = this.state.saveCallback
    if (saveFn) {
      saveFn(reason)
    }
    this.setState({
      exclusionDialogOpen: false,
      saveCallback: null,
      cancelCallback: null
    })
  }

  render () {
    const columns = this.props.columns
    const sortCol = this.props.sortColumn
    const sortDir = this.props.sortDirection
    const data = this.props.data
    const categories = this.props.categories
    const onSortColChange = this.props.onChangeSortColumn
    const onSortDirChange = this.props.onChangeSortDirection
    const onChangeCategory = this.props.onChangeCategory
    const onChangeTemporaryCessation = this.props.onChangeTemporaryCessation

    let exclusionReasonDialog = null

    if (this.props.canExcludeTransactions) {
      exclusionReasonDialog = (
        <ExclusionReasonDialog id='exclusion-dialog'
          show={this.state.exclusionDialogOpen}
          reasons={this.props.exclusionReasons}
          title='Exclude Transaction'
          buttonLabel='Exclude Transaction'
          onSave={this.onSaveExclusionReason}
          onClose={this.onCancelExclusionDialog}
        />
      )
    }

    const rows = this.props.data.map((r) =>
      <TransactionTableRow
        key={r.id}
        columns={columns}
        row={r}
        categories={this.props.categories}
        onChangeCategory={onChangeCategory}
        onChangeTemporaryCessation={onChangeTemporaryCessation}
        onShowExclusionDialog={this.showExclusionDialog}
        onExcludeTransaction={this.props.onExcludeTransaction}
        onReinstateTransaction={this.props.onReinstateTransaction}
        onEditRow={this.props.onEditRow}
        onShowRow={this.props.onShowRow}
      />)

    return (
      <div>
        {exclusionReasonDialog}
      <table className='table table-responsive'>
        <TransactionTableHeader
          columns={columns}
          sortColumn={sortCol}
          sortDirection={sortDir}
          onChangeSortDirection={onSortDirChange}
          onChangeSortColumn={onSortColChange}
        />
        <tbody>
          {rows}
        </tbody>
      </table>
    </div>
    )
  }
}
