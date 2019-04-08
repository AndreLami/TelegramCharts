//
//  ViewController.swift
//  ChartPresenter
//
//  Created by Andre on 3/10/19.
//  Copyright © 2019 BB. All rights reserved.
//

import UIKit

class ChartsViewController: UIViewController {
    
    private var renderBigStage: RenderStage!
    private var graphBigPresenter: ChartPresenter!
    
    private var renderSmallStage: RenderStage!
    private var graphSmallPresenter: ChartPresenter!
    
    private var cropView = CropView()
    
    private var tableView: UITableView?
    private var titleLabel = UILabel.init(frame: .zero)
    private var containerView = UIView.init(frame: .zero)
    
    private var chartsDataProvider: ChartsDataProvider!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return AppThemeManager.shared.currentTheme.isDay ? .default : .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storage = StatisticsStorage()
        let statistic = storage.availableStatistics.last!
        let sparser = DouglasPeukerDataSparser.init(maxPointsPerLevel: 200)
        
        self.chartsDataProvider = ChartsDataProvider.init(withStatistic: statistic, dataSparser: sparser)
       
        self.navigationController?.navigationBar.isTranslucent = false
        
        let viewPort = ViewPort.init(x: self.chartsDataProvider.minAllX, y: 0, xEnd: self.chartsDataProvider.maxAllX, yEnd: 1.0)
        self.view.addSubview(self.containerView)

        
        let bigGraphParams = self.createDefaultChartParams()
        bigGraphParams.xCoordinateLabler = TelegramXAxisDataLabeler()
        bigGraphParams.yCoordinateLabler = TelegramYAxisDataLabeler()
        bigGraphParams.showHighlights = true
        bigGraphParams.highlightInfoViewProvider = TelegramHighlightInfoViewProvider()
        
        self.graphBigPresenter = ChartPresenter.init(withViewPort: viewPort, andParams: bigGraphParams)
        self.graphBigPresenter.updateDataProvider(self.chartsDataProvider)
        
        let smallGraphParams = self.createDefaultChartParams()
        self.graphSmallPresenter = ChartPresenter.init(withViewPort: viewPort, andParams: smallGraphParams)
        self.graphSmallPresenter.updateDataProvider(self.chartsDataProvider)
        
        self.graphSmallPresenter.mainView.addSubview(self.cropView)
        self.cropView.delegate = self
        
        self.containerView.addSubview(self.graphBigPresenter.mainView)
        self.containerView.addSubview(self.graphSmallPresenter.mainView)
        
        
        self.tableView = UITableView.init(frame: .zero, style: .grouped)
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.separatorStyle = .none
        self.tableView?.register(UINib.init(nibName: ChartLineCell.identifier, bundle: nil), forCellReuseIdentifier: ChartLineCell.identifier)
        self.view.addSubview(self.tableView!)
        
        
        self.titleLabel = UILabel.init(frame: .zero)
        self.titleLabel.text = "FOLLOWERS"
        self.titleLabel.textColor = UIColor.init(red: 109.0 / 255.0, green: 109.0 / 255.0, blue: 144.0 / 255.0, alpha: 1.0)
        self.titleLabel.textAlignment = .left
        self.view.addSubview(self.titleLabel)
    
        self.applyTheme(AppThemeManager.shared.currentTheme, animated: false)
    }
    
    
    override func viewWillLayoutSubviews() {
        
        let offset: CGFloat = 30//self.view.safeAreaInsets.top
        
        let viewBounds = self.view.bounds
        
        self.titleLabel.frame = CGRect.init(x: 15, y: offset + 40, width: viewBounds.width - 30, height: 25)
        
        self.containerView.frame = CGRect.init(x: 0, y: self.titleLabel.frame.maxY + 5, width: viewBounds.width, height: 360)
        
        self.graphBigPresenter.mainView.frame = CGRect.init(x: 15, y: 10, width: viewBounds.width - 30, height: 300)
        self.graphSmallPresenter.mainView.frame = CGRect.init(x: 15, y: self.graphBigPresenter.mainView.frame.maxY, width: viewBounds.width - 30, height: 50)
        
        self.cropView.frame = self.graphSmallPresenter.mainView.bounds
        
        self.tableView?.frame = CGRect.init(x: 0, y: self.containerView.frame.maxY, width: viewBounds.width, height: viewBounds.height - self.graphSmallPresenter.mainView.frame.maxY)
    }
    
}

private extension ChartsViewController {
    
    func createDefaultChartParams() -> ChartPresenterParams {
        
        let params = ChartPresenterParams.init(withInitialDisplayMode: AppTheme.night.name)
        params.addDisplayParams(AppTheme.createChartDisplayParams(forTheme: AppTheme.day), forMode: AppTheme.day.name)
        params.addDisplayParams(AppTheme.createChartDisplayParams(forTheme: AppTheme.night), forMode: AppTheme.night.name)
        
        return params
        
    }
    
}

private extension ChartsViewController {
    
    func applyTheme(_ theme: AppTheme, animated: Bool) {
        let params = theme.params
        
        let applyThemeBlock = {
            self.view.backgroundColor = params.primaryBackgroundColor
            self.containerView.backgroundColor = params.secondaryBackgroundColor
            self.tableView?.backgroundColor = params.primaryBackgroundColor
            self.navigationController?.navigationBar.barTintColor = nil
            let navigationViewTextColor = theme.isDay ? UIColor.black : UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : navigationViewTextColor]
            let navigationBarStyle: UIBarStyle = theme.isDay ? .default : .black
            self.navigationController?.navigationBar.barStyle = navigationBarStyle
            let tintColor = theme.isDay ? nil : params.secondaryBackgroundColor
            self.navigationController?.navigationBar.barTintColor = tintColor
         
            self.setNeedsStatusBarAppearanceUpdate()
            self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                applyThemeBlock()
            }
        } else {
            applyThemeBlock()
        }
        
        
        
        self.cropView.applyTheme(theme, animated: animated)
        self.tableView?.reloadData()
        
        self.graphBigPresenter.updateMode(mode: theme.name, animated: animated)
        self.graphSmallPresenter.updateMode(mode: theme.name, animated: animated)
    }
    
}

extension ChartsViewController: CropViewDelegate {
    
    func didChangePositionBar(leftValuePercent: CGFloat, rightValuePercent: CGFloat) {
        let width = (self.chartsDataProvider.maxAllX - self.chartsDataProvider.minAllX)
        let x = self.chartsDataProvider.minAllX + width * leftValuePercent
        let xEnd = self.chartsDataProvider.minAllX + width * rightValuePercent
        
        let update = ViewPort.update().update(x: x).update(xEnd: xEnd)
        
        self.graphBigPresenter.updateViewPort(update, animated: false)
        
    }
}

extension ChartsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        view.backgroundColor = AppThemeManager.currentThemeParams.secondaryBackgroundColor
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 90))
        view.backgroundColor = .clear
        
        let button = UIButton.init(type: .system)
        
        button.backgroundColor = AppThemeManager.currentThemeParams.secondaryBackgroundColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        
        
        button.frame = CGRect.init(x: 0, y: 40, width: tableView.frame.size.width, height: 50)
        button.setTitle("Switch to Night Mode", for: .normal)
        button.addTarget(self, action: #selector(self.switchMode(_:)), for: .touchUpInside)
        
        view.addSubview(button)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChartLineCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chart = self.chartsDataProvider.allCharts[indexPath.row]
        self.chartsDataProvider.toggleEnableChart(withId: chart.id)
        
        self.graphBigPresenter.reloadData()
        self.graphSmallPresenter.reloadData()
        tableView.reloadData()
    }
    
}

extension ChartsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chartsDataProvider.allCharts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ChartLineCell.identifier, for: indexPath) as! ChartLineCell
        let chartData = self.chartsDataProvider.allCharts[indexPath.row]
        
        let enabled = self.chartsDataProvider.isChartEnabled(withId: chartData.id)
        
        cell.updateCell(for: chartData.name!, color: chartData.display?.color)
        cell.accessoryType = enabled ? .checkmark : .none
        
        return cell
    }
    
}

private extension ChartsViewController {
    
    @objc func switchMode(_ sender: UIButton) {
        let currentTheme = AppThemeManager.shared.currentTheme
        let newTheme: AppTheme
        if currentTheme.isDay {
            newTheme = AppTheme.night
        } else {
            newTheme = AppTheme.day
        }
        
        AppThemeManager.shared.currentTheme = newTheme
        
        self.applyTheme(newTheme, animated: true)
    }
    
}

extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default
    }
    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}
