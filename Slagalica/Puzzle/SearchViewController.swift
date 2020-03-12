//
//  SearchViewController.swift
//  Slagalica
//
//  Created by Ivan Almer on 13/08/2019.
//  Copyright © 2019 ialmer. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    private var effectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor.white.withAlphaComponent(0.45)
        return view
    }()
    
    private var searchingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.text = "Searching for solution..."
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        setupConstraints()
        
        view.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        view.addSubview(effectView)
        NSLayoutConstraint.activate([
            effectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            effectView.topAnchor.constraint(equalTo: view.topAnchor),
            effectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: 200),
            containerView.heightAnchor.constraint(equalToConstant: 200),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        containerView.addSubview(searchingLabel)
        NSLayoutConstraint.activate([
            searchingLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            searchingLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            searchingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            searchingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }

}
