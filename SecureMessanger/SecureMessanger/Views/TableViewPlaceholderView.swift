//
//  TableViewPlaceholderView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 22.05.2022.
//

import UIKit

class TableViewPlaceholderView: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private var containerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    private func loadView() {
        Bundle.main.loadNibNamed("TableViewPlaceholderView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    

}
