//
//  ViewController.swift
//  ChartPresenter
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import UIKit

class StatisticViewController: UIViewController {
    
    var statistic: Statistic!
    
    private var renderBigStage: RenderStage!
    private var graphBigPresenter: ChartPresenter!
    
    private var renderSmallStage: RenderStage!
    private var graphSmallPresenter: ChartPresenter!
    
    private var cropView = CropView()
    
    private var titleLabel = UILabel.init(frame: .zero)
    private var containerView = UIView.init(frame: .zero)
    
    private var chartsDataProvider: ChartsDataProvider!
    
    private var stackView = UIStackView()
    
    private var chartLineViewsArray = Array<ChartLineView>()
    
    private weak var modeButton: UIButton?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return AppThemeManager.shared.currentTheme.isDay ? .default : .lightContent
    }
    
    static func initializator(statistic: Statistic) -> StatisticViewController {
        let controller = StatisticViewController.init(nibName: nil, bundle: nil)
        controller.statistic = statistic
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupData()
        self.setupUI()
        
    
        
    }
}

private extension StatisticViewController {
    
    func setupData() {
        
        let minPointsNumber = 175
        let maxPointsNumber = 500
        let resultPointsNumber = max(minPointsNumber, maxPointsNumber / self.statistic.charts.count)
        
        let sparser = DouglasPeukerDataSparser.init(maxPointsPerLevel: resultPointsNumber)
        
        self.chartsDataProvider = ChartsDataProvider.init(withStatistic: self.statistic, dataSparser: sparser)
        
        let viewPort = ViewPort.init(x: self.chartsDataProvider.minAllX, y: 0, xEnd: self.chartsDataProvider.maxAllX, yEnd: 1.0)
        
        let bigGraphParams = self.createDefaultChartParams(lineWidth: 2.0)
        bigGraphParams.xCoordinateLabler = TelegramXAxisDataLabeler()
        bigGraphParams.yCoordinateLabler = TelegramYAxisDataLabeler()
        bigGraphParams.showHighlights = true
        bigGraphParams.highlightInfoViewProvider = TelegramHighlightInfoViewProvider()
        
        self.graphBigPresenter = ChartPresenter.init(withViewPort: viewPort, andParams: bigGraphParams)
        self.graphBigPresenter.updateDataProvider(self.chartsDataProvider)
        
        let smallGraphParams = self.createDefaultChartParams()
        self.graphSmallPresenter = ChartPresenter.init(withViewPort: viewPort, andParams: smallGraphParams)
        self.graphSmallPresenter.updateDataProvider(self.chartsDataProvider)
        
        self.cropView.delegate = self
        
        let themeUpdateListener = AppThemeManager.Listener { [weak self] theme in
            self?.applyTheme(theme, animated: true)
        }
        
        AppThemeManager.shared.addEventListener(themeUpdateListener)
    }
    
    func setupUI() {
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.titleLabel = UILabel.init(frame: .zero)
        self.titleLabel.text = "FOLLOWERS"
        self.titleLabel.textColor = UIColor.init(red: 109.0 / 255.0, green: 109.0 / 255.0, blue: 144.0 / 255.0, alpha: 1.0)
        self.titleLabel.textAlignment = .left
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.titleLabel)
        self.constraintsForTitleLabel()
        
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.containerView)
        self.constraintsForContainerView()

        self.graphBigPresenter.mainView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(self.graphBigPresenter.mainView)
        self.constraintsForBigGraph()

        self.graphSmallPresenter.mainView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(self.graphSmallPresenter.mainView)
        self.constraintsForSmallGraph()

        self.cropView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(self.cropView)
        self.constraintsForCrop()
        
        self.stackView.axis = .vertical
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.stackView)
        self.constraintsForStackView()
        
        self.setupTable()
        self.applyTheme(AppThemeManager.shared.currentTheme, animated: false)

    }
    
    func setupTable() {
        
        self.chartsDataProvider.allCharts.enumerated().forEach { (data) in
            let chartLineView = ChartLineView.init(with: data.element.name ?? "", color: data.element.display?.color)
            chartLineView.hideSeparator(hide: data.offset == self.chartsDataProvider.allCharts.count - 1)
            chartLineView.tag = data.offset
            chartLineView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.didSelectGraph(recognizer:))))
            
            self.stackView.addArrangedSubview(chartLineView)
            chartLineView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            self.chartLineViewsArray.append(chartLineView)
        }
        
        let viewForMode = self.viewForMode()
        self.stackView.addArrangedSubview(viewForMode)
        viewForMode.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
    }
    
    func constraintsForTitleLabel() {
        
        let leadingConstraint = self.titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        leadingConstraint.constant = 15
        leadingConstraint.isActive = true
        
        let tralingConstraint = self.titleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        tralingConstraint.constant = -15
        tralingConstraint.isActive = true
        
        let topConstraint = self.titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor)
        topConstraint.constant = 30
        topConstraint.isActive = true
        
        let height = self.titleLabel.heightAnchor.constraint(equalToConstant: 25)
        height.isActive = true
    }
    
    func constraintsForContainerView() {
        
        let leadingConstraint = self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        leadingConstraint.constant = 0
        leadingConstraint.isActive = true
        
        let tralingConstraint = self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        tralingConstraint.constant = 0
        tralingConstraint.isActive = true
        
        let topConstraint = self.containerView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor)
        topConstraint.constant = 10
        topConstraint.isActive = true
        
        let height = self.containerView.heightAnchor.constraint(equalToConstant: 360)
        height.isActive = true
        
        
    }
    
    func constraintsForBigGraph() {
        
        let leadingConstraint = self.graphBigPresenter.mainView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor)
        leadingConstraint.constant = 15
        leadingConstraint.isActive = true
        
        let tralingConstraint = self.graphBigPresenter.mainView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor)
        tralingConstraint.constant = -15
        tralingConstraint.isActive = true
        
        let topConstraint = self.graphBigPresenter.mainView.topAnchor.constraint(equalTo: self.containerView.topAnchor)
        topConstraint.constant = 0
        topConstraint.isActive = true
        
        let height = self.graphBigPresenter.mainView.heightAnchor.constraint(equalToConstant: 300)
        height.isActive = true
    }
    
    func constraintsForSmallGraph() {
        
        let leadingConstraint = self.graphSmallPresenter.mainView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor)
        leadingConstraint.constant = 15
        leadingConstraint.isActive = true
        
        let tralingConstraint = self.graphSmallPresenter.mainView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor)
        tralingConstraint.constant = -15
        tralingConstraint.isActive = true
        
        let topConstraint = self.graphSmallPresenter.mainView.topAnchor.constraint(equalTo: self.graphBigPresenter.mainView.bottomAnchor)
        topConstraint.constant = 0
        topConstraint.isActive = true
        
        let height = self.graphSmallPresenter.mainView.heightAnchor.constraint(equalToConstant: 50)
        height.isActive = true
    }
    
    func constraintsForCrop() {
        
        let leadingConstraint = self.cropView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor)
        leadingConstraint.constant = 15
        leadingConstraint.isActive = true
        
        let tralingConstraint = self.cropView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor)
        tralingConstraint.constant = -15
        tralingConstraint.isActive = true
        
        let topConstraint = self.cropView.topAnchor.constraint(equalTo: self.graphBigPresenter.mainView.bottomAnchor)
        topConstraint.constant = 0
        topConstraint.isActive = true
        
        let height = self.cropView.heightAnchor.constraint(equalToConstant: 50)
        height.isActive = true
    }
    
    func constraintsForStackView() {
        
        let leadingConstraint = self.stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        leadingConstraint.constant = 0
        leadingConstraint.isActive = true
        
        let tralingConstraint = self.stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        tralingConstraint.constant = 0
        tralingConstraint.isActive = true
        
        let topConstraint = self.stackView.topAnchor.constraint(equalTo: self.containerView.bottomAnchor)
        topConstraint.constant = 0
        topConstraint.isActive = true
        
        let bottomConstraint = self.stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    
        bottomConstraint.isActive = true
        
//        self.stackView.heightAnchor.constraint(equalToConstant: 500).isActive = true
        
    }
    
    func createDefaultChartParams(lineWidth: CGFloat = 1.0) -> ChartPresenterParams {
        
        let params = ChartPresenterParams.init(withInitialDisplayMode: AppTheme.night.name)
        params.addDisplayParams(AppTheme.createChartDisplayParams(forTheme: AppTheme.day, lineWidth:lineWidth), forMode: AppTheme.day.name)
        params.addDisplayParams(AppTheme.createChartDisplayParams(forTheme: AppTheme.night, lineWidth:lineWidth), forMode: AppTheme.night.name)
        
        return params
    }
    
    func viewForMode() -> UIView {
        
        let view = UIView.init()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false

        let switchModeButton = UIButton.init(type: .system)

        switchModeButton.backgroundColor = AppThemeManager.currentThemeParams.secondaryBackgroundColor
        switchModeButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        switchModeButton.addTarget(self, action: #selector(self.switchMode(_:)), for: .touchUpInside)

        
        switchModeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchModeButton)
        
        let leadingConstraint = switchModeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        leadingConstraint.constant = 0
        leadingConstraint.isActive = true
        
        let tralingConstraint = switchModeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        tralingConstraint.constant = 0
        tralingConstraint.isActive = true
        
        let topConstraint = switchModeButton.topAnchor.constraint(equalTo: view.topAnchor)
        topConstraint.constant = 40
        topConstraint.isActive = true
        
        let bottomConstraint = switchModeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.constant = 0
        bottomConstraint.isActive = true
        
        self.modeButton = switchModeButton

        return view
    }
    
}

private extension StatisticViewController {
    
    func applyTheme(_ theme: AppTheme, animated: Bool) {
        let params = theme.params
        
        let applyThemeBlock = {
            self.view.backgroundColor = params.primaryBackgroundColor
            self.containerView.backgroundColor = params.secondaryBackgroundColor
            self.stackView.backgroundColor = params.primaryBackgroundColor
            self.modeButton?.backgroundColor = AppThemeManager.currentThemeParams.secondaryBackgroundColor
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                applyThemeBlock()
            }
        } else {
            applyThemeBlock()
        }
        
        self.cropView.applyTheme(theme, animated: animated)
        self.graphBigPresenter.updateMode(mode: theme.name, animated: animated)
        self.graphSmallPresenter.updateMode(mode: theme.name, animated: animated)
        
        self.chartLineViewsArray.forEach { (view) in
            view.applyTheme(theme, animated: true)
        }
        
        let modeTitle = theme.isDay ? "Switch to Night Mode" : "Switch to Day Mode"
        self.modeButton?.setTitle(modeTitle, for: .normal)
    }
    
    @objc func didSelectGraph(recognizer: UIGestureRecognizer) {
        
        guard let tag = recognizer.view?.tag else {
            return
        }
        
        let chart = self.chartsDataProvider.allCharts[tag]
        self.chartsDataProvider.toggleEnableChart(withId: chart.id)

        self.cropView.isUserInteractionEnabled = !self.chartsDataProvider.isAllChartHidden()
        self.cropView.isHidden = self.chartsDataProvider.isAllChartHidden()

        self.graphBigPresenter.reloadData()
        self.graphSmallPresenter.reloadData()
        
        let enabled = self.chartsDataProvider.isChartEnabled(withId: chart.id)
        
        self.chartLineViewsArray[tag].selected = enabled
    }
}

extension StatisticViewController: CropViewDelegate {
    
    func didChangePositionBar(leftValuePercent: CGFloat, rightValuePercent: CGFloat) {
        let width = (self.chartsDataProvider.maxAllX - self.chartsDataProvider.minAllX)
        let x = self.chartsDataProvider.minAllX + width * leftValuePercent
        let xEnd = self.chartsDataProvider.minAllX + width * rightValuePercent
        
        let update = ViewPort.update().update(x: x).update(xEnd: xEnd)
        
        self.graphBigPresenter.updateViewPort(update, animated: false)
        
    }
}

private extension StatisticViewController {
    
    @objc func switchMode(_ sender: UIButton) {
        let currentTheme = AppThemeManager.shared.currentTheme
        let newTheme: AppTheme
        if currentTheme.isDay {
            newTheme = AppTheme.night
        } else {
            newTheme = AppTheme.day
        }
        
        AppThemeManager.shared.currentTheme = newTheme
    }
    
}
