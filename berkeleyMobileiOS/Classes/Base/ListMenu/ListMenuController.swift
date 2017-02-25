
import UIKit
import Material

fileprivate let kListPadding: CGFloat = 8.0

fileprivate let kCellClass: AnyClass = ListMenuCell.self
fileprivate let kCellName: String    = className(ListMenuCell.self)


/**
 * `ListMenuController` is modal menu controller similar to `UIAlertController` (which cannot be subclassed).
 * 
 */
class ListMenuController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    // Private
    private var items = [ListMenuItem]()
    
    private var overlay = CALayer()//UIView()
    private var tableView = UITableView()
    
    
    // Public
    var message: String?
    var dismissHandler: (() -> Void)? = nil
    
    var clearOnNewSelection: Bool = true
    
    override var modalPresentationStyle: UIModalPresentationStyle 
    {  
        get { return .overFullScreen }
        set {}
    }
    
    override var modalTransitionStyle: UIModalTransitionStyle
    {
        get { return .coverVertical }
        set {}
    }
    
    
    // ========================================
    // MARK: - UIViewController
    // ========================================
    
    required init?(coder aDecoder: NSCoder) 
    {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(message: String?, dismissHandler: (() -> Void)?)
    {
        self.init(nibName: nil, bundle: nil)
        
        self.message = message
        self.dismissHandler = dismissHandler
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupTableView()
        setupDismissTap()
        
        view.backgroundColor = .clear
        overlay.backgroundColor = UIColor.black.cgColor
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
            
        let size = view.bounds.size
        let tableHeight = tableView.contentSize.height
        tableView.frame = CGRect(x: 0, y: size.height - tableHeight, width: size.width, height: tableHeight)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        guard let presenter = presentingViewController else {
            return
        }
        
        let container = presenter.view.layer
        container.addSublayer(overlay)
        overlay.frame = container.bounds
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.5).cgColor
     
        transitionCoordinator?.animate(
            alongsideTransition: { _ in
                self.overlay.backgroundColor = UIColor(white: 0, alpha: 0.5).cgColor
            }, 
            completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        transitionCoordinator?.animate(
            alongsideTransition: { _ in
                self.overlay.backgroundColor = UIColor(white: 0, alpha: 0).cgColor
            }, 
            completion: { _ in
                self.overlay.removeFromSuperlayer()
            })
    }
    
    
    // ========================================
    // MARK: - Private Setup
    // ========================================
    
    private func setupDismissTap()
    {    
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupTableView()
    {
        tableView.register(ListMenuHeader.self, forHeaderFooterViewReuseIdentifier: className(ListMenuHeader.self))
        tableView.register(kCellClass, forCellReuseIdentifier: kCellName)
        
        tableView.rowHeight = ListMenuCell.desiredHeight
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.allowsMultipleSelection = false
        tableView.allowsSelection = true
        tableView.isScrollEnabled = false
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }
    
    private func addCancel()
    {
        addItem(ListMenuItem(text: "Cancel", icon: #imageLiteral(resourceName: "ic_close"), tint: .black, selected: false) 
        { (_) in
            
            self.dismissMenu()
        })
    }
    
    
    // ========================================
    // MARK: - Public
    // ========================================
    
    public func addItem(_ item: ListMenuItem)
    {
        items.append(item)
    }
    
    public func item(at index: Int) -> ListMenuItem?
    {
        guard !items.isEmpty && (0 ..< items.count).contains(index) else
        {
            return nil
        }
        
        return items[index]
    }
    
    @discardableResult
    public func setItem(_ item: ListMenuItem, selected: Bool) -> Bool
    {
        guard let index = (items.index { $0 === item }) else
        {
            // Failed
            return false
        }
        
        if clearOnNewSelection {
            clearAllSelections()
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        tableView.cellForRow(at: indexPath)!.isSelected = selected
        
        item.isSelected = selected
        return true
    }
    
    public func clearAllSelections()
    {
        for i in 0 ..< items.count
        {
            let indexPath = IndexPath(row: i, section: 0)
            tableView.cellForRow(at: indexPath)?.isSelected = false
            
            items[i].isSelected = false
        }
    }
    
    public func dismissMenu()
    {
        guard let presenter = presentingViewController else
        {
            // Error
            return
        }
        
        presenter.dismiss(animated: true, completion: dismissHandler)
    }
    
    
    // ========================================
    // MARK: - UITableViewDataSource
    // ========================================
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellName, for: indexPath) as! ListMenuCell
        cell.setItem(items[indexPath.row])
        
        return cell
    }
    
    
    // ========================================
    // MARK: - UITableViewDelegate
    // ========================================
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 52
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: className(ListMenuHeader.self))
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        guard let header = view as? UITableViewHeaderFooterView else {
            return
        }
        
        header.textLabel?.text = message
        
        header.textLabel?.numberOfLines = 1
        header.textLabel?.lineBreakMode = .byTruncatingTail
        
        header.textLabel?.textColor = Color.grey.darken3
        header.textLabel?.font = RobotoFont.regular(with: 15)
    }
    
    
    // ========================================
    // MARK: - Callback
    // ========================================
    
    func backgroundTapped(_ gesture: UITapGestureRecognizer)
    {
        let point = gesture.location(in: view)
        
        guard !tableView.frame.contains(point) else
        {
            // Do nothing if point is inside tableView.
            return
        }
        
        dismissMenu()
    }
}
