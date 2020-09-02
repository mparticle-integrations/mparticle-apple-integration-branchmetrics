//
//  EventViewController.swift
//  Fortune
//
//  Created by Edward Smith on 2/5/18.
//  Copyright © 2018 Branch. All rights reserved.
//

import UIKit
import mParticle_Apple_SDK
import Branch

func BNCLog(_ level: BNCLogLevel,_ message: String, file: String = #file, line: Int32 = #line) {
    BNCLogWriteMessage(level, file, line, message)
}

class APEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!

    private
    var keyboardEditor: APKeyboardEditor?
    var tableData: APTableData = APTableData.init()
    var branchLink: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableHeaderView = self.headerLabel
        var version:String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        version += " ("
        version += Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        version += ")"
        self.headerLabel.text =
              "Version \(version)"
            + "  iOS \(UIDevice.current.systemVersion)\n"
            + "Branch \(BNC_SDK_VERSION)"
            + "  mParticle \(MParticle.sharedInstance().version)\n"
            ;
        self.headerLabel.sizeToFit()
        var r = self.headerLabel.bounds
        r.size.height += 26
        self.headerLabel.bounds = r

        self.tableData.addSection(title: "Life Cycle Events")
        let row = self.tableData.addRow(title: "Tracking Disabled", style: .toggleSwitch, selector: #selector(enableTracking(toggle:)))
        row.integerValue = MParticle.sharedInstance().optOut ? 1 : 0

        self.tableData.addRow(title: "Set User Identity", style: .plain, selector:#selector(setIdentity(row:)))
        self.tableData.addRow(title: "Set User Alias", style: .plain, selector:#selector(startSetIdentityAlias(row:)))
        self.tableData.addRow(title: "Log User Out", style: .plain, selector:#selector(logUserOut(row:)))

        self.tableData.addSection(title: "Branch Links")
        self.tableData.addRow(title: "Create Branch Link", style: .plain, selector:#selector(createBranchLink(row:)))
        self.tableData.addRow(title: "Open Branch Link", style: .plain) { (row) in
            if let link = self.branchLink,
               let url = URL.init(string: link) {
                Branch.getInstance().resetUserSession()
                UIApplication.shared.openURL(url)
            } else {
                self.showAlert(title: "No Branch Link", message: "Create a Branch link first!")
            }
        }

        self.tableData.addSection(title: "View Events")
        self.tableData.addRow(title: "View Screen - Simple", style: .plain, selector:#selector(logScreenSimple(row:)))
        self.tableData.addRow(title: "View Screen - Complex", style: .plain, selector:#selector(logScreenComplex(row:)))

        self.tableData.addSection(title: "Standard Events")
        self.tableData.addRow(title: "Navigation", style: .plain, action: { row in
            let e = self.createEvent(name:"\(row.title) Event", type:.navigation)
            MParticle.sharedInstance().logEvent(e)
        })
        self.tableData.addRow(title: "Location", style: .plain, action: { row in
            let e = self.createEvent(name:"\(row.title) Event", type:.location)
            MParticle.sharedInstance().logEvent(e)
        })
        self.tableData.addRow(title: "Search", style: .plain, action: { row in
            let e = self.createEvent(name:"\(row.title) Event", type:.search)
            MParticle.sharedInstance().logEvent(e)
        })
        self.tableData.addRow(title: "Transaction", style: .plain, action: { row in
            let e = self.createEvent(name:"\(row.title) Event", type:.transaction)
            MParticle.sharedInstance().logEvent(e)
        })
        self.tableData.addRow(title: "User Content", style: .plain, action: { row in
            let e = self.createEvent(name:"\(row.title) Event", type:.userContent)
            MParticle.sharedInstance().logEvent(e)
        })
        self.tableData.addRow(title: "User Preference", style: .plain, action: { row in
            let e = self.createEvent(name:"\(row.title) Event", type:.userPreference)
            MParticle.sharedInstance().logEvent(e)
        })
        self.tableData.addRow(title: "Social", style: .plain, action: { row in
            let e = self.createEvent(name:"\(row.title) Event", type:.social)
            MParticle.sharedInstance().logEvent(e)
        })
        self.tableData.addRow(title: "Other", style: .plain, action: { row in
            let e = self.createEvent(name:"\(row.title) Event", type:.other)
            MParticle.sharedInstance().logEvent(e)
        })
        self.tableData.addRow(title: "Purchase", style: .plain, action: { row in
            let e = self.createEvent(name:"\(row.title) Event", type:.purchase)
            MParticle.sharedInstance().logEvent(e)
        })

        self.tableData.addSection(title: "Promotion Events")
        self.tableData.addRow(title: "View Promotion", style: .plain, selector:#selector(promotionViewEvent(row:)))
        self.tableData.addRow(title: "Click Promotion", style: .plain, selector:#selector(promotionClickEvent(row:)))

        self.tableData.addSection(title: "Commerce Events")
        self.tableData.addRow(title: "Log Impression", style: .plain, selector:#selector(impressionEvent(row:)))
        self.tableData.addRow(title: "Add to Cart", style: .plain, selector:#selector(addToCartEvent(row:)))
        self.tableData.addRow(title: "Remove from Cart", style: .plain, selector:#selector(removeFromCartEvent(row:)))
        self.tableData.addRow(title: "Add to Wishlist", style: .plain, selector:#selector(addToWishlistEvent(row:)))
        self.tableData.addRow(title: "Remove from Wishlist", style: .plain, selector:#selector(removeFromWishlistEvent(row:)))
        self.tableData.addRow(title: "Checkout", style: .plain, selector:#selector(checkoutEvent(row:)))
        self.tableData.addRow(title: "Checkout with Options", style: .plain, selector:#selector(checkoutOptionsEvent(row:)))
        self.tableData.addRow(title: "Click", style: .plain, selector:#selector(clickEvent(row:)))
        self.tableData.addRow(title: "View Detail", style: .plain, selector:#selector(viewDetailEvent(row:)))
        self.tableData.addRow(title: "Purchase", style: .plain, selector:#selector(purchaseEvent(row:)))
        self.tableData.addRow(title: "Refund", style: .plain, selector:#selector(refundEvent(row:)))

        self.tableView.tableFooterView = UIView()
        self.tableView.tableFooterView?.backgroundColor = .clear
    }

    // MARK: - Table View Delegate & Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableData.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.numberOfRowsIn(section: section)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableData.section(section: section).title
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier:"cell")
            ?? UITableViewCell.init(style: .value1, reuseIdentifier: "cell")
        let row = self.tableData.row(indexPath:indexPath)
        cell.textLabel?.text = row.title
        cell.detailTextLabel?.text = nil
        cell.accessoryView = nil;
        cell.accessoryType = .none;
        cell.selectionStyle = .default;
        if (row.style == .disclosure) {
            cell.accessoryType = .disclosureIndicator;
            cell.detailTextLabel?.text = row.stringValue;
        } else
        if (row.style == .plain) {
            cell.accessoryType = .none;
            cell.detailTextLabel?.text = row.stringValue;
        } else
        if (row.style == .toggleSwitch) {
            let sw = UISwitch.init()
            sw.isOn = row.integerValue == nil ? false : row.integerValue != 0
            sw.onTintColor = .red
            sw.addTarget(self, action:row.selector!, for:.valueChanged)
            cell.accessoryView = sw
            cell.selectionStyle = .none;
        }
        return cell;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.tableData.row(indexPath:indexPath)
        BNCLog(.debug, "Selected index \(indexPath.section):\(indexPath.row): \(row.title).")
        if (row.style != .toggleSwitch) {
            if (row.selector != nil) {
                self.perform(row.selector, with:row)
            } else
            if (row.action != nil) {
                row.action!(row)
            }
        }
        self.tableView.deselectRow(at:indexPath, animated:true)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel.init()
        label.text = self.tableData.section(section: section).title
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false

        let view = UIView.init()
        view.addSubview(label)
        view.backgroundColor = UIColor.init(white: 0.98, alpha: 0.90)
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.50).cgColor
        view.layer.borderWidth = 0.50

        let views = ["label" : label]
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-20-[label]-20-|",
            metrics: nil,
            views: views
        )
        constraints += NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[label]|",
            metrics: nil,
            views: views
        )
        NSLayoutConstraint.activate(constraints)
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }

    // MARK: - User Events

    @IBAction func enableTracking(toggle: UISwitch?) {
        if  let toggle = toggle,
            let cell = toggle.superview as! UITableViewCell?,
            let row = self.tableData.rowFor(tableView: self.tableView, cell: cell) {
            let val = toggle.isOn as Bool
            MParticle.sharedInstance().optOut = val
            row.integerValue = val ? 1 : 0
            self.tableData.update(tableView:self.tableView, row:row)
        }
    }

    @IBAction func setIdentity(row: AnyObject) {
        let request = MPIdentityApiRequest.withEmptyUser()
        request.email = "foo@example.com"
        request.customerId = "cust_123456"
        request.setIdentity("bar-id", identityType: MPIdentity.other)
        MParticle.sharedInstance().identity.login(request, completion: nil)
    }

    @IBAction func startSetIdentityAlias(row: AnyObject) {
        self.promptForAlias { (alias) in
            if let alias = alias, alias.count > 0 {
                self.finishSetIdentityAlias(alias: alias)
            }
        }
    }

    func promptForAlias(completion: ((String?) -> Void)?) {
        if self.keyboardEditor != nil { return }
        self.keyboardEditor = APKeyboardEditor.presentFromViewController(
            viewController: self,
            completion: { (resultText) in
                completion?(resultText)
                self.keyboardEditor = nil
            }
        )
    }

    func finishSetIdentityAlias(alias: String) {
        let request = MPIdentityApiRequest.withEmptyUser()
        request.setIdentity(alias, identityType: MPIdentity.other)

        // TODO: This has been deprecated and removed.   Switch to mParticleIdentityStateChangeListener
//        request.onUserAlias = { (previousUser, newUser) -> Void in
//
//            //copy anything that you want from the previous to the new user
//            //this snippet would copy everything
//
//            newUser.userAttributes = previousUser.userAttributes
//
//            let products = previousUser.cart.products() ?? []
//            if (products.count > 0) {
//                newUser.cart.addAllProducts(products, shouldLogEvents: false)
//            }
//        }
        MParticle.sharedInstance().identity.login(request, completion: nil)
    }

    @IBAction func logUserOut(row: AnyObject) {
        // MParticle.sharedInstance().logout()  <- Old?
        MParticle.sharedInstance().identity.logout { (result, error) in
            BNCLog(.debug, "Logged out.")
        }
    }

    // MARK: - Deep Links

    @IBAction func createBranchLink(row: AnyObject?) {
        let message = APAppData.shared.randomFortune()

        // Add some content to the Branch object:
        let buo = BranchUniversalObject.init()
        buo.title = "Branch Example"
        buo.contentDescription = "A mysterious fortune."
        buo.contentMetadata.customMetadata["message"] = message
        buo.contentMetadata.customMetadata["name"] = UIDevice.current.name

        // Set some link properties:
        let linkProperties = BranchLinkProperties.init()
        linkProperties.channel = "Fortune"

        // Get the link:
        buo.getShortUrl(with: linkProperties) { (urlString: String?, error: Error?) in
            if let urlString = urlString {
                APAppData.shared.linksCreated += 1
                self.branchLink = urlString
                if let row = row as! APTableRow? {
                    row.stringValue = urlString
                    self.tableData.update(tableView: self.tableView, row: row)
                }
                return
            }
            self.showAlert(title: "Error", message: String(describing: error))
        }
    }

    // MARK: - Screen Events

    @IBAction func logScreenSimple(row: AnyObject) {
        MParticle.sharedInstance().logScreen("Awesome Screen Simple", eventInfo: [
            "modal":    "false",
            "color":    "green"
        ])
    }

    @IBAction func logScreenComplex(row: AnyObject) {
        if let event = MPEvent.init(name: "Awesome Screen Complex", type: .userContent) {
            event.info = [
                "modal": "false",
                "color": "green"
            ]
            MParticle.sharedInstance().logScreenEvent(event)
        }
    }

    // MARK: - Standard Events

    func createEvent(name: String, type: MPEventType) -> MPEvent {
        let e = MPEvent.init(name: name, type: type) ?? MPEvent.init()
        e.category = "Toys & Games"
        e.addCustomFlag("CustomFlag", withKey:"CustomValue")
        if (e.info == nil) {
            e.info = ["InfoVal": "InfoKey"]
        } else {
            e.info?["InfoVal"] = "InfoKey"
        }
        return e
    }

    // MARK: - Commerce Events

    func createProduct(number: Int) -> MPProduct {
        /*
        @property (nonatomic, strong, nullable) NSString *brand;
        @property (nonatomic, strong, nullable) NSString *category;
        @property (nonatomic, strong, nullable) NSString *couponCode;
        @property (nonatomic, strong, nonnull) NSString *name;
        @property (nonatomic, strong, nullable) NSNumber *price;
        @property (nonatomic, strong, nonnull) NSString *sku;
        @property (nonatomic, strong, nullable) NSString *variant;
        @property (nonatomic, unsafe_unretained) NSUInteger position;
        @property (nonatomic, strong, nonnull) NSNumber *quantity;
        */

        let p = MPProduct.init()
        p.brand = "Brand-\(number)"
        p.category = "Category-\(number)"
        p.couponCode = "Coupon-\(number)"
        p.name = "Name-\(number)"
        p.price = NSNumber.init(value: number)
        p.sku = "Sku-\(number)"
        p.variant = "Variant-\(number)"
        p.position = UInt(number)
        p.quantity = NSNumber.init(value: number)
        return p
    }

    func products() -> [MPProduct] {
        var products: [MPProduct] = []
        for i in 1...2 {
            let p = self.createProduct(number: i)
            products.append(p)
        }
        return products
    }

    func createCommerceEvent(action: MPCommerceEventAction) -> MPCommerceEvent {
        /*
        Commerce event fields:

        @property (nonatomic, strong, nullable) NSString *checkoutOptions;
        @property (nonatomic, strong, nullable) NSString *currency;
        @property (nonatomic, strong, readonly, nullable) NSDictionary<NSString *, __kindof NSSet<MPProduct *> *> *impressions;
        @property (nonatomic, strong, readonly, nullable) NSArray<MPProduct *> *products;
        @property (nonatomic, strong, nullable) MPPromotionContainer *promotionContainer;
        @property (nonatomic, strong, nullable) NSString *productListName;
        @property (nonatomic, strong, nullable) NSString *productListSource;
        @property (nonatomic, strong, nullable) NSString *screenName;
        @property (nonatomic, strong, nullable) MPTransactionAttributes *transactionAttributes;
        @property (nonatomic, unsafe_unretained) MPCommerceEventAction action;
        @property (nonatomic, unsafe_unretained) NSInteger checkoutStep;
        @property (nonatomic, unsafe_unretained) BOOL nonInteractive; // Non-interactive refund.

        - (nonnull instancetype)initWithPromotionContainer:(nullable MPPromotionContainer *)promotionContainer;
        - (void)addImpression:(nonnull MPProduct *)product listName:(nonnull NSString *)listName;
        - (void)addProduct:(nonnull MPProduct *)product;
        - (void)setCustomAttributes:(nullable NSDictionary<NSString *, NSString *> *)customAttributes;
        */

        let e = MPCommerceEvent.init(action: action) ?? MPCommerceEvent.init()
        e.checkoutOptions = "Checkout Options"
        e.currency = "USD"
        e.productListName = "List-Name"
        e.productListSource = "List-Source"
        e.screenName = "Screen-Name"
        e.checkoutStep = 1
        e.nonInteractive = true

        // Add products --
        e.addProducts(self.products())

        // Add custom attibutes --
        //e.setCustomAttributes(["CustomKey": "CustomValue"])

        // Add a transaction --
        /*
        @property (nonatomic, strong, nullable) NSString *affiliation;
        @property (nonatomic, strong, nullable) NSString *couponCode;
        @property (nonatomic, strong, nullable) NSNumber *shipping;
        @property (nonatomic, strong, nullable) NSNumber *tax;
        @property (nonatomic, strong, nullable) NSNumber *revenue;
        @property (nonatomic, strong, nullable) NSString *transactionId;
        */
        let t = MPTransactionAttributes()
        t.affiliation = "T-Affiliation-1"
        t.couponCode = "T-Coupon-1"
        t.shipping = 1.00
        t.tax = 2.00
        t.revenue = 3.00
        t.transactionId = "T-Transaction-Id"
        e.transactionAttributes = t

        return e
    }

    @IBAction func promotionViewEvent(row: AnyObject) {
        /*
        @property (nonatomic, strong, nullable) NSString *creative;
        @property (nonatomic, strong, nullable) NSString *name;
        @property (nonatomic, strong, nullable) NSString *position;
        @property (nonatomic, strong, nullable) NSString *promotionId;
        */
        let promotion = MPPromotion.init()
        promotion.promotionId = "my_promo_1"
        promotion.creative = "sale_banner_1"
        promotion.name = "App-wide 50% off sale"
        promotion.position = "dashboard_bottom"

        let container = MPPromotionContainer.init(action:.view, promotion: promotion)
        let event = MPCommerceEvent.init(promotionContainer: container)
        MParticle.sharedInstance().logCommerceEvent(event)
    }

    @IBAction func promotionClickEvent(row: AnyObject) {
        /*
        @property (nonatomic, strong, nullable) NSString *creative;
        @property (nonatomic, strong, nullable) NSString *name;
        @property (nonatomic, strong, nullable) NSString *position;
        @property (nonatomic, strong, nullable) NSString *promotionId;
        */
        let promotion = MPPromotion.init()
        promotion.promotionId = "my_promo_1"
        promotion.creative = "sale_banner_1"
        promotion.name = "App-wide 50% off sale"
        promotion.position = "dashboard_bottom"

        let container = MPPromotionContainer.init(action:.click, promotion: promotion)
        let event = MPCommerceEvent.init(promotionContainer: container)
        MParticle.sharedInstance().logCommerceEvent(event)
    }

    @IBAction func impressionEvent(row: AnyObject) {
        let product = self.createProduct(number: 1)
        let event = MPCommerceEvent.init(impressionName: "Suggest Products List", product: product)
        MParticle.sharedInstance().logCommerceEvent(event)
    }

    @IBAction func addToCartEvent(row: AnyObject) {
        let e = self.createCommerceEvent(action: .addToCart)
        MParticle.sharedInstance().logCommerceEvent(e)
    }

    @IBAction func removeFromCartEvent(row: AnyObject) {
        let e = self.createCommerceEvent(action: .removeFromCart)
        MParticle.sharedInstance().logCommerceEvent(e)
    }

    @IBAction func addToWishlistEvent(row: AnyObject) {
        let e = self.createCommerceEvent(action: .addToWishList)
        MParticle.sharedInstance().logCommerceEvent(e)
    }

    @IBAction func removeFromWishlistEvent(row: AnyObject) {
        let e = self.createCommerceEvent(action: .removeFromWishlist)
        MParticle.sharedInstance().logCommerceEvent(e)
    }

    @IBAction func checkoutEvent(row: AnyObject) {
        let e = self.createCommerceEvent(action: .checkout)
        MParticle.sharedInstance().logCommerceEvent(e)
    }

    @IBAction func checkoutOptionsEvent(row: AnyObject) {
        let e = self.createCommerceEvent(action: .checkoutOptions)
        MParticle.sharedInstance().logCommerceEvent(e)
    }

    @IBAction func clickEvent(row: AnyObject) {
        let e = self.createCommerceEvent(action: .click)
        MParticle.sharedInstance().logCommerceEvent(e)
    }

    @IBAction func viewDetailEvent(row: AnyObject) {
        let e = self.createCommerceEvent(action: .viewDetail)
        MParticle.sharedInstance().logCommerceEvent(e)
    }

    @IBAction func purchaseEvent(row: AnyObject) {
        let e = self.createCommerceEvent(action: .purchase)
        MParticle.sharedInstance().logCommerceEvent(e)
    }

    @IBAction func refundEvent(row: AnyObject) {
        let e = self.createCommerceEvent(action: .refund)
        MParticle.sharedInstance().logCommerceEvent(e)
    }
}
