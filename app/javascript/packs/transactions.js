/* eslint no-console:0 */
import 'babel-polyfill'
import React from 'react'
import ReactDOM from 'react-dom'
import TransactionsView from '../components/TransactionsView'
import DataFileView from '../components/DataFileView'
import Constants from '../components/constants'

const loadEvent = (typeof Turbolinks !== 'undefined') ? 'turbolinks:load' : 'DOMContentLoaded'
const unloadEvent = (typeof Turbolinks !== 'undefined') ? 'turbolinks:before-render' : 'beforeunload'

document.addEventListener(loadEvent, () => {
  if (document.getElementById('transaction-table')) {
    const element = document.getElementById('transaction-table')
    const regime = element.getAttribute('data-regime')
    const showSummary = element.getAttribute('data-with-summary') === 'true'
    const sortColumn = element.getAttribute('data-sort-col')
    const sortDir = element.getAttribute('data-sort-dir')
    // const viewModes = Constants.VIEW_MODES

    // const summaryPath = element.getAttribute('data-summary-path')
    // const generateFilePath = element.getAttribute('data-generate-file-path')
    const selectedRegion = element.getAttribute('data-selected-region')
    const searchPlaceholder = element.getAttribute('data-search-placeholder')
    const searchTerm = element.getAttribute('data-search-term')
    const categories = JSON.parse(element.getAttribute('data-categories'))
    const csrfToken = document.querySelector('meta[name=csrf-token]').content
    const generateFiles = element.getAttribute('data-generate-files') === 'true'
    const viewMode = element.getAttribute('data-view-mode') 

    ReactDOM.render(
      <TransactionsView
        regime={regime}
        showSummary={showSummary}
        sortColumn={sortColumn}
        sortDirection={sortDir}
        categories={categories}
        csrfToken={csrfToken}
        selectedRegion={selectedRegion}
        searchTerm={searchTerm}
        searchPlaceholder={searchPlaceholder}
        generateFiles={generateFiles}
        viewMode={viewMode}
      />,
      element
    )
  } else if (document.getElementById('data-file-view')) {
    const element = document.getElementById('data-file-view')
    const regime = element.getAttribute('data-regime')
    const columns = Constants.DATA_FILE_COLUMNS
    const sortColumn = element.getAttribute('data-sort-col')
    const sortDir = element.getAttribute('data-sort-dir')
    const path = element.getAttribute('data-path')
    const errorPath = element.getAttribute('data-error-path')
    const filename = element.getAttribute('data-filename')
    const uploadDate = element.getAttribute('data-upload-date')
    const status = element.getAttribute('data-status')
    const successCount = element.getAttribute('data-success-count')
    const failedCount = element.getAttribute('data-failed-count')
    const errors = JSON.parse(element.getAttribute('data-errors'))
    const csrfToken = document.querySelector('meta[name=csrf-token]').content

    ReactDOM.render(
      <DataFileView
      regime={regime}
      columns={columns}
      sortColumn={sortColumn}
      sortDirection={sortDir}
      path={path}
      errors={errors}
      filename={filename}
      uploadDate={uploadDate}
      status={status}
      successCount={successCount}
      failedCount={failedCount}
      csrfToken={csrfToken}
      />,
      element
    )
  }
})

document.addEventListener(unloadEvent, () => {
  const element = document.getElementById('transaction-table') || document.getElementById('data-file-view')

  if(element) {
    ReactDOM.unmountComponentAtNode(element)
  }
})
