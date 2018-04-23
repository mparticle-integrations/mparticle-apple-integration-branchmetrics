//
//  APTableData.swift
//  Fortune
//
//  Created by Edward Smith on 3/22/18.
//  Copyright © 2018 Branch. All rights reserved.
//

import UIKit

enum APRowStyle {
    case
        plain,
        disclosure,
        toggleSwitch
}

class APTableItem {
    var title: String = ""
}

class APTableRow : APTableItem {
    var stringValue: String?
    var integerValue: Int?
    var selector: Selector?
    var action: ((APTableRow) -> Void)?
    var style: APRowStyle = .plain
}

class APTableSection : APTableItem {
}

class  APTableData  {
    private var sections: Array<APTableSection> = []
    private var rows: Array<Array<APTableRow>> = []

    func numberOfSections() -> Int {
        return self.sections.count
    }

    func numberOfRowsIn(section: Int) -> Int {
        return self.rows[section].count
    }

    func row(indexPath: IndexPath) -> APTableRow {
        return self.rows[indexPath.section][indexPath.row]
    }

    func section(section: Int) -> APTableSection {
        return self.sections[section]
    }

    @discardableResult
    func addSection(title: String) -> APTableSection {
        let section = APTableSection.init()
        section.title = title
        self.sections.append(section)
        self.rows.append([])
        return section
    }

    @discardableResult
    func addRow(title: String, style: APRowStyle, selector: Selector?) -> APTableRow {
        let row = APTableRow.init()
        row.title = title
        row.style = style
        row.selector = selector
        var idx = self.rows.count
        if idx == 0 {
            self.rows.append([])
            idx += 1
        }
        self.rows[idx-1].append(row)
        return row
    }

    @discardableResult
    func addRow(title: String, style: APRowStyle, action: ((APTableRow) -> Void)?) -> APTableRow {
        let row = APTableRow.init()
        row.title = title
        row.style = style
        row.action = action
        var idx = self.rows.count
        if idx == 0 {
            self.rows.append([])
            idx += 1
        }
        self.rows[idx-1].append(row)
        return row

    }

    func indexPath(row: APTableRow) -> IndexPath? {
        var rowIndex = 0
        var sectionIndex = 0
        for sections in self.rows {
            for row in sections {
                if row === row {
                    return IndexPath.init(row: rowIndex, section:sectionIndex)
                }
                rowIndex += 1
            }
            rowIndex = 0
            sectionIndex += 1
        }
        return nil;
    }

    func cellFor(tableView: UITableView, row: APTableRow) -> UITableViewCell? {
        if let indexPath = self.indexPath(row: row) {
            return tableView.cellForRow(at: indexPath)
        }
        return nil
    }

    func update(tableView: UITableView, row: APTableRow) {
        if let indexPath = self.indexPath(row: row) {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    func rowFor(tableView: UITableView, cell: UITableViewCell) -> APTableRow? {
        if let indexPath = tableView.indexPath(for: cell) {
            let row = self.row(indexPath: indexPath)
            return row
        }
        return nil
    }
}
