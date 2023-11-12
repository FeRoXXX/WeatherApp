//
//  typeOfWeatherCell.swift
//  WeatherApp
//
//  Created by Александр Федоткин on 05.11.2023.
//

import UIKit

class typeOfWeatherCell: UITableViewCell {
   
    @IBOutlet weak var dayLable: UILabel!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var minTemp: UILabel!
    
    @IBOutlet weak var maxTemp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
