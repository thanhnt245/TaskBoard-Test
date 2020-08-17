//
//  TasksViewController.swift
//  TaskManagement
//
//  Created by Thanh Nguyen on 8/16/20.
//  Copyright © 2020 Thanh Nguyen. All rights reserved.
//

import UIKit

final class TasksViewController: BaseViewController {
    var viewModel: TasksBoardViewModel = TasksBoardViewModel()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dragImgView: UIImageView!

    var draggingItem: (User, DailyTask, IndexPath)?
    var previousDragPoint: CGPoint = .zero

    private var autoScrollTimer: Timer?
    private var scrollXRate: CGFloat = 0
    private var scrollYRate: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        dragImgView.layer.borderColor = UIColor.lightGray.cgColor
        dragImgView.layer.borderWidth = 1.0
        dragImgView.layer.shadowColor = UIColor.darkGray.cgColor
        dragImgView.layer.shadowOffset = .zero
        dragImgView.layer.shadowRadius = 10
        dragImgView.layer.shadowOpacity = 1.0
        
        collectionView.bounces = false
        let workStartTime = viewModel.workingDayStartTime
        // Creat default 10 users
        for i in 1...10 {
            viewModel.users.append(AppUser(name: "User \(i)", tasks: [AppDailyTask(startTime: workStartTime + 30 * i)]))
        }
        viewModel.reCalculate()
        (collectionView.collectionViewLayout as? SpreadsheetCollectionViewLayout)?.delegate = self
        collectionView.reloadData()

        autoScrollTimer = Timer(timeInterval: 0.2, target: self, selector: #selector(scrollCollectionViewIfNeeded), userInfo: nil, repeats: true)
        RunLoop.main.add(autoScrollTimer!, forMode: RunLoop.Mode.common)
    }

    @objc func scrollCollectionViewIfNeeded() {
        guard scrollXRate != 0 || scrollYRate != 0 else {
            return
        }
        if collectionView.contentOffset.x + scrollXRate >= -collectionView.contentInset.left &&
            collectionView.contentOffset.x + scrollXRate <= collectionView.contentSize.width - collectionView.bounds.width + collectionView.contentInset.right {
            collectionView.contentOffset.x += scrollXRate
        } else {
            scrollXRate = 0
        }
        if collectionView.contentOffset.y + scrollYRate >= -collectionView.contentInset.top &&
            collectionView.contentOffset.y + scrollYRate <= collectionView.contentSize.height - collectionView.bounds.height + collectionView.contentInset.bottom {
            collectionView.contentOffset.y += scrollYRate
        } else {
            scrollYRate = 0
        }
    }
    
    @IBAction func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        let pointInView = gesture.location(in: view)
        let pointInCollectionView = gesture.location(in: collectionView)
        switch gesture.state {
        case .began:
            if let indexPath = collectionView.indexPathForItem(at: pointInCollectionView), indexPath.row != 0, indexPath.section != 0, let cell = collectionView.cellForItem(at: indexPath) {
                let user = viewModel.users[indexPath.section - 1]
                let timeSlot = viewModel.timeSlots[indexPath.row - 1]
                if let task = viewModel.getTaskForUser(user, time: timeSlot) {
                    draggingItem = (user, task, indexPath)
                    let image = UIImage(view: cell)
                    dragImgView.image = image
                    dragImgView.frame = cell.convert(cell.bounds, to: view)
                    UIView.animate(withDuration: 0.3, animations: {
                        self.dragImgView.isHidden = false
                    }, completion: { success in
                        self.collectionView.reloadItems(at: [indexPath])
                    })
                }
            }
        case .changed:
            guard let _ = draggingItem else {
                dragImgView.isHidden = true
                return
            }

            scrollXRate = 0
            scrollYRate = 0
            let insetRect = collectionView.frame.inset(by: UIEdgeInsets(top: 60, left: 90, bottom: 10, right: 10))
            if !insetRect.contains(pointInView) {
                if pointInView.x < insetRect.minX {
                    scrollXRate = -15
                }
                if pointInView.x > insetRect.maxX {
                    scrollXRate = 15
                }
                if pointInView.y < insetRect.minY {
                    scrollYRate = -15
                }
                if pointInView.y > insetRect.maxY {
                    scrollYRate = +15
                }
            }

            dragImgView.center.x += (pointInView.x - previousDragPoint.x)
            dragImgView.center.y += (pointInView.y - previousDragPoint.y)
        case .ended, .cancelled:
            scrollXRate = 0
            scrollYRate = 0
            guard let item = draggingItem else {
                dragImgView.isHidden = true
                return
            }
            let dragViewCenterInCollectionView = view.convert(dragImgView.center, to: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: dragViewCenterInCollectionView), indexPath.row != 0, indexPath.section != 0, let cell = collectionView.cellForItem(at: indexPath) {
                var user = viewModel.users[indexPath.section - 1]
                let timeSlot = viewModel.timeSlots[indexPath.row - 1]
                if viewModel.getTaskForUser(user, time: timeSlot) == nil {
                    // Move task to new position
                    var preUser = item.0
                    var preTask = item.1

                    if let index = preUser.tasks.firstIndex(where: {$0.startTime == preTask.startTime}) {
                        preUser.tasks.remove(at: index)
                    }

                    preTask.startTime = timeSlot
                    user.tasks.append(preTask)
                    UIView.animate(withDuration: 0.3, animations: {
                        self.dragImgView.center = cell.superview?.convert(cell.center, to: self.view) ?? .zero
                    }) { (success) in
                        self.draggingItem = nil
                        self.dragImgView.isHidden = true
                        self.collectionView.reloadData()
                    }
                    return
                }
            }

            // Move back
            var destinationCenter: CGPoint = .zero
            if let preCell = collectionView.cellForItem(at: item.2) {
                destinationCenter = preCell.superview?.convert(preCell.center, to: self.view) ?? .zero
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.dragImgView.center = destinationCenter
            }) { (success) in
                self.draggingItem = nil
                self.dragImgView.isHidden = true
                self.collectionView.reloadItems(at: [item.2])
            }
        default:
            break
        }
        previousDragPoint = pointInView
    }
}

extension TasksViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.users.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.timeSlots.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(UserCell.self)", for: indexPath) as? UserCell {
                cell.nameLabel.text = ""
                return cell
            }
        case (0, _):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TimeSlotCell.self)", for: indexPath) as? TimeSlotCell {
                cell.timeSlotLabel.text = viewModel.timeSlotsString[indexPath.row - 1]
                return cell
            }
        case (_, 0):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(UserCell.self)", for: indexPath) as? UserCell {
                cell.nameLabel.text = viewModel.users[indexPath.section - 1].name
                return cell
            }
        default:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TaskCell.self)", for: indexPath) as? TaskCell {
                cell.bgView.backgroundColor = .clear
                cell.taskNameLabel.text = ""
                cell.contentView.alpha = 1.0
                let user = viewModel.users[indexPath.section - 1]
                let timeSlot = viewModel.timeSlots[indexPath.row - 1]
                if let task = viewModel.getTaskForUser(user, time: timeSlot) {
                    cell.bgView.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
                    cell.taskNameLabel.text = task.description
                    cell.contentView.alpha = (indexPath != draggingItem?.2) ? 1.0 : 0.6
                }

                return cell
            }
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section != 0 && indexPath.row != 0 else {
            return
        }
        var user = viewModel.users[indexPath.section - 1]
        let timeSlot = viewModel.timeSlots[indexPath.row - 1]
        if var task = viewModel.getTaskForUser(user, time: timeSlot) {
            // Edit task
            let editAlert = UIAlertController(title: "Edit Task", message: nil, preferredStyle: .alert)
            editAlert.addTextField()
            editAlert.textFields?.first?.text = task.description

            let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned editAlert] _ in
                let textValue = editAlert.textFields![0].text ?? "--"
                task.description = textValue
                self.collectionView.reloadItems(at: [indexPath])
            }
            editAlert.addAction(submitAction)
            editAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(editAlert, animated: true)
        } else {
            // Add task
            let addTaskAlert = UIAlertController(title: "New Task", message: nil, preferredStyle: .alert)
            addTaskAlert.addTextField()

            let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned addTaskAlert] _ in
                let textValue = addTaskAlert.textFields![0].text ?? "--"
                user.tasks.append(AppDailyTask(startTime: timeSlot, description: textValue))
                self.collectionView.reloadItems(at: [indexPath])
            }
            addTaskAlert.addAction(submitAction)
            addTaskAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(addTaskAlert, animated: true)
        }
    }
}

extension TasksViewController: SpreadsheetCollectionViewLayoutDelegate {
    func width(forColumn column: Int, collectionView: UICollectionView) -> CGFloat {
        return 80
    }
    func height(forRow row: Int, collectionView: UICollectionView) -> CGFloat {
        return 50
    }
}
