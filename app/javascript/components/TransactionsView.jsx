import React from 'react'
import axios from 'axios'
import TransactionSummary from './TransactionSummary'
import TransactionTable from './TransactionTable'
import PaginationBar from './PaginationBar'
import OptionSelector from './OptionSelector'
import Constants from './constants'
import TransactionSearchBox from './TransactionSearchBox'

export default class TransactionsView extends React.Component {
  constructor (props) {
    super(props)
    const transactions = this.props.transactions || this.emptyTransactions()

    const selectedRegion = this.props.selectedRegion || ''
    const selectedFinancialYear = this.props.selectedFinancialYear || ''
    const viewMode = this.props.viewMode || Constants.VIEW_MODE_NAMES[0]
    const columns = this.tableColumns(viewMode)

    this.state = {
      viewMode: viewMode,
      tableColumns: columns,
      sortColumn: this.props.sortColumn,
      sortDirection: this.props.sortDirection,
      transactions: transactions,
      selectedRegion: selectedRegion,
      selectedFinancialYear: selectedFinancialYear,
      searchTerm: this.props.searchTerm,
      pageSize: transactions.pagination.per_page,
      currentPage: transactions.pagination.current_page,
      summary: this.emptySummary(),
      reasons: [],
      fileSummaryOpen: false,
      regionOptions: [{label: 'All', value: ''}],
      financialYearOptions: [{label: 'All', value: ''}]
    }

    this.changeViewMode = this.changeViewMode.bind(this)
    this.changeFinancialYear = this.changeFinancialYear.bind(this)
    this.toggleSortDirection = this.toggleSortDirection.bind(this)
    this.changeSortColumn = this.changeSortColumn.bind(this)
    this.changeRegion = this.changeRegion.bind(this)
    this.search = this.search.bind(this)
    this.changePage = this.changePage.bind(this)
    this.changePageSize = this.changePageSize.bind(this)
    this.updateTransactionCategory = this.updateTransactionCategory.bind(this)
    this.updateTemporaryCessation = this.updateTemporaryCessation.bind(this)
    this.showFileSummary = this.showFileSummary.bind(this)
    this.hideFileSummary = this.hideFileSummary.bind(this)
    this.exportTransactions = this.exportTransactions.bind(this)
    this.excludeTransaction = this.excludeTransaction.bind(this)
    this.reinstateTransaction = this.reinstateTransaction.bind(this)
    this.fetchExclusionReasons()
  }

  tableColumns (viewMode) {
    return Constants[this.props.regime.toUpperCase() + '_COLUMNS'][viewMode]
  }

  emptyTransactions () {
    const perPage = 10
    return {
      pagination: {
        per_page: perPage,
        current_page: 1
      },
      transactions: [{id: 1}]
    }
  }

  emptySummary () {
    return {
      credit_count: 0,
      credit_total: 0,
      invoice_count: 0,
      invoice_total: 0,
      net_total: 0
    }
  }

  changeViewMode(mode) {
    const columns = this.tableColumns(mode)
    // switch between TTBB, History and Retrospective views of the data
    this.setState({
      viewMode: mode,
      currentPage: 1,
      tableColumns: columns
    }, () => {
      this.fetchTableData()
    })
  }

  changeFinancialYear (fy) {
    this.setState({selectedFinancialYear: fy}, () => {
      this.fetchTableData()
    })
  }

  toggleSortDirection () {
    const direction = this.state.sortDirection === 'asc' ? 'desc' : 'asc'
    this.setState({sortDirection: direction, currentPage: 1}, () => {
      this.fetchTableData()
    })
  }

  changeSortColumn (columnName) {
    this.setState({sortColumn: columnName, sortDirection: 'asc', currentPage: 1}, () => {
      this.fetchTableData()
    })
  }

  changeRegion (region) {
    this.setState({selectedRegion: region, currentPage: 1}, () => {
      this.fetchTableData()
    })
  }

  search (term) {
    this.setState({searchTerm: term, currentPage: 1}, () => {
      this.fetchTableData()
    })
  }

  changePage (page) {
    this.setState({currentPage: page}, () => {
      this.fetchTableData()
    })
  }

  changePageSize (size) {
    // need to ensure we don't fall off the end into no-man's land by being on
    // the last page and making the page size larger
    const pagination = this.state.transactions.pagination
    const total = pagination.total_count
    const pageSize = this.state.pageSize
    let currentPage = this.state.currentPage
    const numPages = (total / size) + 1

    if (numPages < currentPage) {
      currentPage = Math.max(1, numPages)
    }

    this.setState({pageSize: size, currentPage: currentPage}, () => {
      this.fetchTableData()
    })
  }

  showFileSummary () {
    this.fetchSummaryDataAndShow()
    // query for all transactions to be billed that have a charge generated for them
    // but exclude any that have are part of multi-transactions if one or more other
    // items haven't had charges generated
  }

  hideFileSummary () {
    this.setState({fileSummaryOpen: false})
  }

  exportTransactions () {
    let uri = this.transactionPath('path') + '.csv'
    uri += '?region=' + encodeURIComponent(this.state.selectedRegion)
    uri += '&search=' + encodeURIComponent(this.state.searchTerm)
    uri += '&sort=' + encodeURIComponent(this.state.sortColumn)
    uri += '&sort_direction=' + encodeURIComponent(this.state.sortDirection)
    console.log("do export:" + uri)
    window.location.replace(uri)
  }

  excludeTransaction(id, reason) {
    console.log('Exclude ' + id + ' - ' + reason)
    this.updateExclusionFlag(id, true, reason)
  }

  reinstateTransaction(id) {
    console.log('Reinstate ' + id)
    this.updateExclusionFlag(id, false, null)
  }

  generateFile () {
    console.log('generate file')
  }

  componentDidMount () {
    this.fetchTableData()
  }

  fetchTableData () {
    axios.get(this.transactionPath('path') + '.json', {
      params: {
        sort: this.state.sortColumn,
        sort_direction: this.state.sortDirection,
        region: this.state.selectedRegion,
        fy: this.state.selectedFinancialYear,
        search: this.state.searchTerm,
        page: this.state.currentPage,
        per_page: this.state.pageSize
      }
    })
      .then(res => {
        this.setState({
          transactions: res.data,
          pagination: res.data.pagination,
          pageSize: res.data.pagination.per_page,
          currentPage: res.data.pagination.current_page,
          selectedRegion: res.data.selected_region,
          regionOptions: res.data.regions,
          financialYearOptions: res.data.financial_years
        })
      })
      .catch(error => {
        this.handleXhrError(error)
      })
  }

  handleXhrError(error) {
    // more than likely we've got a 401 because our session has timed-out
    if (error.response.status === 401) {
      // force reauthentication
      window.location.reload(true)
    } else {
      console.log(error)
      throw error
    }
  }

  fetchSummaryDataAndShow () {
    axios.get(this.transactionPath('summaryPath') + '.json', {
      params: {
        region: this.state.selectedRegion
      }
    })
      .then(res => {
        this.setState({
          summary: res.data,
          fileSummaryOpen: true
        })
      })
      .catch(error => {
        this.handleXhrError(error)
      })
  }

  fetchExclusionReasons () {
    const path = '/regimes/' + this.props.regime + '/exclusion_reasons.json'

    axios.get(path)
      .then(res => {
        this.setState({
          reasons: res.data,
        })
      })
      .catch(error => {
        this.handleXhrError(error)
      })
  }

  updateTransactionCategory (id, value) {
    this.updateRowForSlowNetwork(id, 'sroc_category', value)
    this.doUpdate(id, {
      category: value
    })
  }

  updateTemporaryCessation (id, value) {
    const showVal = (value === '1') ? 'Y' : 'N'
    this.updateRowForSlowNetwork(id, 'temporary_cessation', showVal)
    this.doUpdate(id, {
      temporary_cessation: value
    })
  }

  updateExclusionFlag (id, excluded, reason) {
    console.log('update exclusion: ' + id + ' ' + excluded + ' ' + reason)
    this.doUpdate(id, {
      excluded: excluded,
      excluded_reason: reason
    })
  }

  updateRowForSlowNetwork(id, attr, value) {
    let data = this.state.transactions
    let idx = data.transactions.findIndex(t => {
      return t.id === id
    })
    if (idx !== -1) {
      data.transactions[idx][attr] = value
      data.transactions[idx].amount = 'Working...'
      this.setState({ transactions: data })
    }
  }

  doUpdate(id, value) {
    axios.patch(this.transactionPath('path') + '/' + id + '.json',
      {
        transaction_detail: value
      },
      {
        headers: {
          'X-CSRF-Token': this.props.csrfToken
        }
      })
    .then(res => {
      // update local data
      let data = this.state.transactions
      let idx = data.transactions.findIndex(t => {
        return t.id === id
      })
      if (idx !== -1) {
        data.transactions[idx] = res.data.transaction
        this.setState({ transactions: data })
      }
    })
    .catch(error => {
      this.handleXhrError(error)
    })
  }

  currentViewMode () {
    return Constants.VIEW_MODES[this.state.viewMode]
  }

  transactionPath (key) {
    const regime = this.props.regime
    const mode = this.currentViewMode()
    return '/regimes/' + regime + mode[key]
  }

  render () {
    const viewMode = this.state.viewMode
    const regime = this.props.regime
    const columns = this.state.tableColumns
    const sortColumn = this.state.sortColumn
    const sortDirection = this.state.sortDirection
    const transactions = this.state.transactions.transactions
    const pagination = this.state.transactions.pagination
    const regions = this.state.regionOptions
    const selectedRegion = this.state.selectedRegion
    const searchTerm = this.state.seachTerm
    const searchPlaceholder = this.props.searchPlaceholder
    const currentPage = this.state.currentPage
    const pageSize = this.state.pageSize
    const summary = this.state.summary
    const categories = this.props.categories
    const canGenerateFiles = this.props.generateFiles && (viewMode === 'unbilled' || viewMode === 'retrospective')
    const generateFilePath = this.transactionPath('generatePath')
    const csrfToken = this.props.csrfToken
    const financialYearOptions = this.state.financialYearOptions
    const selectedFinancialYear = this.state.selectedFinancialYear
    const fileType = (viewMode === 'retrospective' ? 'Retrospective' : 'Transaction')
    const fileDialogTitle = fileType + ' File'
    const generateButtonLabel = 'Generate ' + fileType + ' File'
    const showExportButton = (viewMode === 'unbilled' || viewMode == 'historic')
    const canExcludeTransactions = (viewMode === 'unbilled')
    const exclusionReasons = this.state.reasons

    let fileButton = null
    let fileDialog = null

    if (canGenerateFiles) {
      fileButton = (
        <button className='btn btn-primary mr-4' onClick={this.showFileSummary}>
          {generateButtonLabel}
        </button>
      )
      fileDialog = (
        <TransactionSummary id='summary-dialog2112'
          show={this.state.fileSummaryOpen}
          summary={summary}
          generateFilePath={generateFilePath}
          region={selectedRegion}
          csrfToken={csrfToken}
          title={fileDialogTitle}
          buttonLabel={generateButtonLabel}
          onClose={this.hideFileSummary} />
      )
    }

    const modes = Constants.VIEW_MODE_NAMES.map((name, i) => {
      return {label: Constants.VIEW_MODES[name].label, value: name}
    })

    let financialYearSelector = null
    // history and exclusion views only
    if(viewMode === 'historic' || viewMode === 'excluded') {
      financialYearSelector = (
        <div className='mr-4'>
          <OptionSelector selectedValue={selectedFinancialYear}
            label='FY'
            className='form-control'
            options={financialYearOptions}
            name='financial-year'
            id='financial-year'
            onChange={this.changeFinancialYear}
          />
        </div>
      )
    }

    return (
      <div className={viewMode}>
        <div className="row mb-4">
          <div className="col">
            <h1>{this.currentViewMode().label}</h1>
          </div>
        </div>
        <div className='row search-bar'>
          <div className='col mb-2 form-inline'>
            <div className='mr-4'>
              <OptionSelector selectedValue={viewMode}
                label='View'
                className='form-control'
                options={modes}
                name='mode'
                id='mode-select'
                onChange={this.changeViewMode}
              />
            </div>
            <div className='mr-4'>
              <OptionSelector selectedValue={selectedRegion}
                label='Region'
                className='form-control'
                options={regions}
                name='region'
                id='regions'
                onChange={this.changeRegion}
              />
            </div>
            {financialYearSelector}
            <TransactionSearchBox placeholder={searchPlaceholder}
              searchTerm={searchTerm} onSearch={this.search}
            />
            {fileButton}
          </div>
        </div>
        <TransactionTable regime={regime}
          columns={columns}
          sortColumn={sortColumn}
          sortDirection={sortDirection}
          data={transactions}
          categories={this.props.categories}
          onChangeSortDirection={this.toggleSortDirection}
          onChangeSortColumn={this.changeSortColumn}
          onChangeCategory={this.updateTransactionCategory}
          onChangeTemporaryCessation={this.updateTemporaryCessation}
          onExcludeTransaction={this.excludeTransaction}
          onReinstateTransaction={this.reinstateTransaction}
          canExcludeTransactions={canExcludeTransactions}
          exclusionReasons={exclusionReasons}
        />
        <PaginationBar pagination={pagination}
          useMatchingLabel={true}
          pageSize={pageSize}
          currentPage={currentPage}
          showExportButton={showExportButton}
          onChangePageSize={this.changePageSize}
          onChangePage={this.changePage}
          onExportTransactions={this.exportTransactions}
        />
        {fileDialog}
      </div>
    )
  }
}
