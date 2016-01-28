import Foundation
import UIKit
import SafariServices
import Parse
import ParseUI

class SponsorsViewController: PFQueryCollectionViewController {
    
    private let cellIdentifier = "sponsorCell"

    // MARK: - Initializers
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout(), className: "UMAD_Sponsor")
        collectionView?.registerClass(PFCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        navigationItem.title = "Partners"
        pullToRefreshEnabled = false
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }

    // MARK: - SponsorsViewController
    
    private func companyAtIndexPath(indexPath: NSIndexPath) -> Company? {
        let sponsors = objects as? [UMADSponsor]
        let sponsorAtIndexPath = sponsors?[indexPath.row]
        return sponsorAtIndexPath?.company
    }
    
    // MARK: - PFQueryCollectionViewController

    override func queryForCollection() -> PFQuery {
        let query = UMADSponsor.query()!
        query.cachePolicy = .CacheThenNetwork
        query.includeKey("company")
        if let currentUMAD = AppDelegate.currentUMAD {
            query.whereKey("umad", equalTo: currentUMAD)
        }
        return query
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {

        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as? PFCollectionViewCell,
            company = companyAtIndexPath(indexPath) else {
            return nil
        }
        cell.imageView.image = UIImage(named: "placeholder")
        cell.imageView.file = company.image
        cell.imageView.loadInBackground()
        return cell
    }
    
    // MARK: - UICollectionViewDelegate

     override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let selectedCompany = companyAtIndexPath(indexPath) else {
            return
        }
        let safariViewController = SFSafariViewController(URL: selectedCompany.websiteURL)
        safariViewController.view.tintColor = Config.tintColor
        presentViewController(safariViewController, animated: true, completion: nil)
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (view.frame.width / 2.3) - 10, height: 100)
    }
    
}
