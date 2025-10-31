import Foundation
import UIKit

class SimpleTableView: UIView, ResourceLinkBlockViewRepresentable {
    var context: [CodingUserInfoKey : Any] = [:]
    private let tableView: UITableView
    private var rows: [SimpleTableViewRow]
    private var measuredWidth: CGFloat = 0
    private var measuredHeight: CGFloat = 0

    func layout(with width: CGFloat) {
        guard width > 0 && !rows.isEmpty else {
            measuredWidth = 0
            measuredHeight = 0
            invalidateIntrinsicContentSize()
            return
        }

        var totalHeight: CGFloat = 0
        for row in rows {
            row.layout(with: width)
            totalHeight += row.intrinsicContentSize.height
        }

        measuredWidth = width
        measuredHeight = totalHeight
        self.frame.size = CGSize(width: measuredWidth, height: measuredHeight)

        // Update table view height
        tableView.frame = CGRect(x: 0, y: 0, width: measuredWidth, height: measuredHeight)
        tableView.reloadData()

        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        // Return the measured width and height
        return CGSize(width: measuredWidth, height: measuredHeight)
    }

    init(rows: [SimpleTableViewRow]) {
        self.rows = rows
        self.tableView = UITableView(frame: .zero, style: .plain)
        super.init(frame: .zero)

        setContentCompressionResistancePriority(.required, for: .vertical)

        // Configure table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RichTextTableViewRowCell.self, forCellReuseIdentifier: "RichTextTableViewRowCell")
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear

        addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 177/255, green: 193/255, blue: 203/255, alpha: 1).cgColor
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDataSource
extension SimpleTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RichTextTableViewRowCell",
            for: indexPath
        ) as? RichTextTableViewRowCell else {
            return UITableViewCell()
        }

        let row = rows[indexPath.row]
        cell.configure(with: row)
        cell.selectionStyle = .none

        return cell
    }
}

// MARK: - UITableViewDelegate
extension SimpleTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = rows[indexPath.row]
        return row.intrinsicContentSize.height
    }
}

// MARK: - TableViewRowCell
private class RichTextTableViewRowCell: UITableViewCell {
    private var rowView: SimpleTableViewRow?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with row: SimpleTableViewRow) {
        // Remove previous row view if any
        rowView?.removeFromSuperview()

        // Add new row view
        rowView = row
        contentView.addSubview(row)

        row.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: contentView.topAnchor),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        rowView?.removeFromSuperview()
        rowView = nil
    }
}
