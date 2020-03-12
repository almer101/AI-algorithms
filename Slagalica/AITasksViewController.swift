//
//  AITasksViewController.swift
//  Slagalica
//
//  Created by Ivan Almer on 13/08/2019.
//  Copyright © 2019 ialmer. All rights reserved.
//

import UIKit

class AITasksViewController: UIViewController {

    @IBOutlet weak var puzzleButton: UIButton!
    @IBOutlet weak var antColonyButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func puzzleButtonTapped(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PuzzleViewController") as? PuzzleViewController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func antColonyButtonTapped(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AntColonyViewController") as? AntColonyViewController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
