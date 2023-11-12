//
//  HeaderCollectionReusableView.swift
//  WeatherApp
//
//  Created by Александр Федоткин on 09.11.2023.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
        static let identifier = "HeaderCollectionReusableView"
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Ожидаются осадки"
        return label
    }()
    public func configure(){
        backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
}
