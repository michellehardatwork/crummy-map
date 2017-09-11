//
//  SearchViewController.swift
//  CrummyMap
//
//  Created by Michelle Cervenka 9/9/17.
//  Copyright © 2017 Michelle Cervenka. All rights reserved.
//

import UIKit

private enum State {
    case none
    case initial
    case searching
    case searched
}

public class SearchViewController: UITableViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableViewMessageView: SearchTableStateView!
    weak var searchViewDelegate: SearchViewDelegate?

    fileprivate let locationService = LocationService()
    fileprivate var locations: [Location] = []

    override public func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self

        tableView.backgroundView = tableViewMessageView
        tableView.tableFooterView = UIView()

        currentState = .initial
    }

    fileprivate var currentState = State.none {
        didSet {
            switch currentState {
            case .initial:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                tableViewMessageView.showInitial()
                break
            case .searching:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                tableViewMessageView.showSearching()
                break
            case .searched:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                tableViewMessageView.showSearched(count: locations.count)
                break
            case .none:
                tableViewMessageView.showNothing()
                break
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController {

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell

        cell.textLabel?.text = locations[indexPath.row].description

        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController {

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideSearchView()
        searchViewDelegate?.searchView(self, didSelectLocation: locations[indexPath.row])
    }

    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //Adding as section header instead of table header so it will stick to the top when scrolling
        return searchBar
    }

    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {

    func search() {

        guard let searchText = searchBar.text, !searchText.isEmpty else {
            // There is no search text so we will not search
            return
        }

        currentState = .searching

        //Cancel previous searches
        locationService.cancel()

        //Perform new search
        locationService.search(searchTerm: searchText) { [weak self] result in

            guard let strongSelf = self else {
                return
            }

            switch result {
            case .success(let locations):

                // Successful Search - update the UI
                strongSelf.locations = locations
                strongSelf.tableView.reloadData()
                strongSelf.tableView.setContentOffset(CGPoint.zero, animated: false)
                break

            case .failure(let error):

                guard (error as NSError).code != NSURLErrorCancelled else {
                    //We expect a cancelled request since we are the ones cancelling it
                    break
                }

                // Failed Search - show the error
                strongSelf.showError(error)
                break
            }

            strongSelf.currentState = .searched
        }
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // to limit network activity, reload a second after last key press.
        cancelSearch()

        guard let searchText = searchBar.text, !searchText.isEmpty else {
            currentState = .initial
            locations.removeAll()
            tableView.reloadData()
            return
        }

        delaySearch()
    }

    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        showSearchView()
    }

    // called when cancel button pressed
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       hideSearchView()
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        cancelSearch()
        search()
    }

    fileprivate func delaySearch() {
        // Delaying the search by 1 second so we don't overload the backend
        perform(#selector(self.search), with: nil, afterDelay: 1.0)
    }

    fileprivate func cancelSearch() {
        // Cancel any previous delayed requests to search because it is obsolete.
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.search), object: nil)
    }

    fileprivate func showSearchView() {
        searchBar.becomeFirstResponder()
        searchBar.setShowsCancelButton(true, animated: true)
        searchViewDelegate?.searchViewDidBeginSearching(self)
    }

    fileprivate func hideSearchView() {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchViewDelegate?.searchViewDidEndSearching(self)
    }
}

// MARK: - Error Handling

extension SearchViewController {
    fileprivate func showError(_ error: Error?) {
        guard let error = error else {
            return
        }

        let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Search State View

class SearchTableStateView: UIView {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var stateMessageLabel: UILabel!

    private lazy var paragraphStyle: NSMutableParagraphStyle = {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 5.0
        return paragraph
    }()

    private lazy var titleStyle: [String : Any] = {
        return [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightBold),
                NSForegroundColorAttributeName: UIColor.darkText,
                NSParagraphStyleAttributeName: self.paragraphStyle]
    }()

    private lazy var descriptionStyle: [String : Any] = {
        return [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor.darkGray,
                NSParagraphStyleAttributeName: self.paragraphStyle]
    }()

    func showNothing() {
        activityIndicator.stopAnimating()
        stateImage.image = nil
        stateMessageLabel.text = ""
    }

    func showInitial() {
        activityIndicator.stopAnimating()
        stateImage.image = UIImage(named:"find")

        let title = "Search Crummy"
        let description = "\nI’m not sure what crummy is, but I’m sure it is great!"

        let titleString = NSAttributedString(string: title, attributes: titleStyle)
        let descriptionString = NSAttributedString(string: description, attributes: descriptionStyle)

        let combination = NSMutableAttributedString()
        combination.append(titleString)
        combination.append(descriptionString)

        stateMessageLabel.attributedText = combination
    }

    func showSearching() {
        activityIndicator.startAnimating()
        stateImage.image = nil
        stateMessageLabel.text = ""
    }

    func showSearched(count: Int) {
        activityIndicator.stopAnimating()

        if count <= 0 {
            stateImage.image = (count > 0) ? nil : UIImage(named:"empty")
            let title = "No Crummy Found"
            let titleString = NSAttributedString(string: title, attributes: titleStyle)

            stateMessageLabel.attributedText = titleString
        } else {
            showNothing()
        }
    }
}
