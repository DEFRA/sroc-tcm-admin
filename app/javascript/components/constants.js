'use strict'

const Constants = module.exports = {}

Constants.PAS_COLUMNS = { 
  unbilled: [
    { name: 'original_filename',
      label: 'File Reference',
      sortable: true,
      editable: false
    }, {
      name: 'original_file_date',
      label: 'File Date',
      sortable: true,
      editable: false
    }, {
      name: 'customer_reference',
      label: 'Customer',
      sortable: true,
      editable: false
    }, {
      name: 'permit_reference',
      label: 'Permit',
      sortable: true,
      editable: false
    }, {
      name: 'original_permit_reference',
      label: 'Original Permit',
      sortable: true,
      editable: false
    }, {
      name: 'sroc_category',
      label: 'SRoC Category',
      sortable: true,
      editable: true
    }, {
      name: 'compliance_band',
      label: 'Compliance Band',
      sortable: true,
      editable: false
    }, {
      name: 'temporary_cessation',
      label: 'TC',
      access_label: 'Temporary Cessation',
      sortable: false,
      editable: true
    }, {
      name: 'period',
      label: 'Period',
      sortable: true,
      editable: false
    }, {
      name: 'amount',
      label: 'Amount (£)',
      sortable: false,
      editable: false,
      rightAlign: true
    }
  ],
  historic: [
    { name: 'customer_reference',
      label: 'Customer',
      sortable: true,
      editable: false
    }, {
      name: 'permit_reference',
      label: 'Permit',
      sortable: true,
      editable: false
    }, {
      name: 'original_permit_reference',
      label: 'Original Permit',
      sortable: true,
      editable: false
    }, {
      name: 'sroc_category',
      label: 'SRoC Category',
      sortable: true,
      editable: false
    }, {
      name: 'temporary_cessation',
      label: 'TC',
      access_label: 'Temporary Cessation',
      sortable: true,
      editable: false
    }, {
      name: 'compliance_band',
      label: 'Compliance Band',
      sortable: true,
      editable: false
    }, {
      name: 'period',
      label: 'Period',
      sortable: true,
      editable: false
    }, {
      name: 'amount',
      label: 'Amount (£)',
      sortable: true,
      editable: false,
      rightAlign: true
    }, {
      name: 'original_filename',
      label: 'File (Src)',
      sortable: true,
      editable: false
    }, {
      name: 'generated_filename',
      label: 'File (TCM)',
      sortable: true,
      editable: false
    }, {
      name: 'tcm_transaction_reference',
      label: 'Transaction Ref',
      access_label: 'Transaction Reference',
      sortable: true,
      editable: false
    }
  ],
  retrospective: [
    { name: 'customer_reference',
      label: 'Customer',
      sortable: true,
      editable: false
    }, {
      name: 'permit_reference',
      label: 'Permit',
      sortable: true,
      editable: false
    }, {
      name: 'original_permit_reference',
      label: 'Original Permit',
      sortable: true,
      editable: false
    }, {
      name: 'compliance_band',
      label: 'Compliance Band',
      sortable: true,
      editable: false
    }, {
      name: 'period',
      label: 'Period',
      sortable: true,
      editable: false
    }, {
      name: 'amount',
      label: 'Amount (£)',
      sortable: false,
      editable: false,
      rightAlign: true
    }
  ]
}

Constants.CFD_COLUMNS = {
  unbilled: [
    { name: 'original_filename',
      label: 'File Reference',
      sortable: true,
      editable: false
    }, {
      name: 'original_file_date',
      label: 'File Date',
      sortable: true,
      editable: false
    }, {
      name: 'customer_reference',
      label: 'Customer',
      sortable: true,
      editable: false
    }, {
      name: 'consent_reference',
      label: 'Consent',
      sortable: true,
      editable: false
    }, {
      name: 'version',
      label: 'Ver',
      access_label: 'Version',
      sortable: false,
      editable: false
    }, {
      name: 'discharge',
      label: 'Dis',
      access_label: 'Discharge',
      sortable: false,
      editable: false
    }, {
      name: 'sroc_category',
      label: 'SRoC Category',
      sortable: true,
      editable: true
    }, {
      name: 'variation',
      label: '%',
      access_label: 'Variation Percentage',
      sortable: true,
      editable: false
    }, {
      name: 'temporary_cessation',
      label: 'TC',
      access_label: 'Temporary Cessation',
      sortable: false,
      editable: true
    }, {
      name: 'period',
      label: 'Period',
      sortable: true,
      editable: false
    }, {
      name: 'amount',
      label: 'Amount (£)',
      sortable: false,
      editable: false,
      rightAlign: true
    }
  ],
  historic: [
    {
      name: 'customer_reference',
      label: 'Customer',
      sortable: true,
      editable: false
    }, {
      name: 'consent_reference',
      label: 'Consent',
      sortable: true,
      editable: false
    }, {
      name: 'version',
      label: 'Ver',
      access_label: 'Version',
      sortable: true,
      editable: false
    }, {
      name: 'discharge',
      label: 'Dis',
      access_label: 'Discharge',
      sortable: true,
      editable: false
    }, {
      name: 'sroc_category',
      label: 'SRoC Category',
      sortable: true,
      editable: false
    }, {
      name: 'variation',
      label: '%',
      access_label: 'Variation Percentage',
      sortable: true,
      editable: false
    }, {
      name: 'temporary_cessation',
      label: 'TC',
      access_label: 'Temporary Cessation',
      sortable: true,
      editable: false
    }, {
      name: 'period',
      label: 'Period',
      sortable: true,
      editable: false
    }, {
      name: 'amount',
      label: 'Amount (£)',
      sortable: true,
      editable: false,
      rightAlign: true
    }, {
      name: 'original_filename',
      label: 'File (Src)',
      sortable: true,
      editable: false
    }, {
      name: 'generated_filename',
      label: 'File (TCM)',
      sortable: true,
      editable: false
    }, {
      name: 'tcm_transaction_reference',
      label: 'Transaction Ref',
      access_label: 'Transaction Reference',
      sortable: true,
      editable: false
    }
  ],
  retrospective: [
    { name: 'original_filename',
      label: 'File Reference',
      sortable: true,
      editable: false
    }, {
      name: 'original_file_date',
      label: 'File Date',
      sortable: true,
      editable: false
    }, {
      name: 'customer_reference',
      label: 'Customer',
      sortable: true,
      editable: false
    }, {
      name: 'consent_reference',
      label: 'Consent',
      sortable: true,
      editable: false
    }, {
      name: 'version',
      label: 'Ver',
      access_label: 'Version',
      sortable: false,
      editable: false
    }, {
      name: 'discharge',
      label: 'Dis',
      access_label: 'Discharge',
      sortable: false,
      editable: false
    }, {
      name: 'variation',
      label: '%',
      access_label: 'Variation Percentage',
      sortable: true,
      editable: false
    }, {
      name: 'period',
      label: 'Period',
      sortable: true,
      editable: false
    }, {
      name: 'line_amount',
      label: 'Amount (£)',
      sortable: false,
      editable: false,
      rightAlign: true
    }
  ]
}

Constants.WML_COLUMNS = {
  unbilled: [
    { name: 'original_filename',
      label: 'File Reference',
      sortable: true,
      editable: false
    }, {
      name: 'original_file_date',
      label: 'File Date',
      sortable: true,
      editable: false
    }, {
      name: 'customer_reference',
      label: 'Customer',
      sortable: true,
      editable: false
    }, {
      name: 'permit_reference',
      label: 'Permit',
      sortable: true,
      editable: false
    }, {
      name: 'sroc_category',
      label: 'SRoC Category',
      sortable: true,
      editable: true
    }, {
      name: 'compliance_band',
      label: 'Compliance Band',
      sortable: true,
      editable: false
    }, {
      name: 'temporary_cessation',
      label: 'TC',
      access_label: 'Temporary Cessation',
      sortable: false,
      editable: true
    }, {
      name: 'period',
      label: 'Period',
      sortable: true,
      editable: false
    }, {
      name: 'amount',
      label: 'Amount (£)',
      sortable: false,
      editable: false,
      rightAlign: true
    }
  ],
  historic: [
    { name: 'customer_reference',
      label: 'Customer',
      sortable: true,
      editable: false
    }, {
      name: 'permit_reference',
      label: 'Permit',
      sortable: true,
      editable: false
    }, {
      name: 'original_permit_reference',
      label: 'Original Permit',
      sortable: true,
      editable: false
    }, {
      name: 'sroc_category',
      label: 'SRoC Category',
      sortable: true,
      editable: false
    }, {
      name: 'temporary_cessation',
      label: 'TC',
      access_label: 'Temporary Cessation',
      sortable: true,
      editable: false
    }, {
      name: 'compliance_band',
      label: 'Compliance Band',
      sortable: true,
      editable: false
    }, {
      name: 'period',
      label: 'Period',
      sortable: true,
      editable: false
    }, {
      name: 'amount',
      label: 'Amount (£)',
      sortable: true,
      editable: false,
      rightAlign: true
    }, {
      name: 'original_filename',
      label: 'File (Src)',
      sortable: true,
      editable: false
    }, {
      name: 'generated_filename',
      label: 'File (TCM)',
      sortable: true,
      editable: false
    }, {
      name: 'tcm_transaction_reference',
      label: 'Transaction Ref',
      access_label: 'Transaction Reference',
      sortable: true,
      editable: false
    }
  ],
  retrospective: [
    { name: 'customer_reference',
      label: 'Customer',
      sortable: true,
      editable: false
    }, {
      name: 'permit_reference',
      label: 'Permit',
      sortable: true,
      editable: false
    }, {
      name: 'compliance_band',
      label: 'Compliance Band',
      sortable: true,
      editable: false
    }, {
      name: 'period',
      label: 'Period',
      sortable: true,
      editable: false
    }, {
      name: 'amount',
      label: 'Amount (£)',
      sortable: false,
      editable: false,
      rightAlign: true
    }
  ]
}

Constants.DATA_FILE_COLUMNS = [
  { name: 'line_number',
    label: 'Line No',
    sortable: true,
    editable: false
  }, {
    name: 'message',
    label: 'Description',
    sortable: true,
    editable: false
  }
]

Constants.VIEW_MODE_NAMES = [
  'unbilled',
  'historic',
  'retrospective'
]

Constants.VIEW_MODES = {
  unbilled: {
    name: 'transactions',
    label: 'Transactions to be billed',
    path: '/transactions',
    summaryPath: '/transaction_summary',
    generatePath: '/transaction_files'
  },
  historic: {
    name: 'history',
    label: 'Transaction History',
    path: '/history'
  },
  retrospective: {
    name: 'retrospective',
    label: 'Retrospectives to be billed',
    path: '/retrospectives',
    summaryPath: '/retrospective_summary',
    generatePath: '/retrospective_files'
  }//,
  // { name: 'retrospective_history',
  //   label: 'Retrospective History',
  //   path: '/retrospective_history'
  // }
}

// Constants.regimeColumns = (regime, history) => {
//   let cols = null
//   if (regime === 'pas') {
//     cols = Constants.INSTALLATIONS_COLUMNS
//   } else if (regime === 'cfd') {
//     cols = Constants.WATER_QUALITY_COLUMNS
//   } else if (regime === 'wml') {
//     cols = Constants.WASTE_COLUMNS
//   } else {
//     throw new Error('Unknown regime: ' + regime)
//   }
//
//   if (history) {
//     // if historic data the remove the editable flag to prevent modification
//     cols = cols.map(c => {
//       c.editable = false
//       return c
//     })
//   }
//
//   return cols
// }
