//
//  AddViewTableViewController.swift
//  unifysocialsharing
//
//  Created by Jan-Hendrik Telke on 04/06/16.
//  Copyright © 2016 jannhendrik. All rights reserved.
//

import UIKit
import CocoaBloc_Camera

class AddViewTableViewController: UITableViewController,  SBCaptureViewControllerDelegate{
    @IBOutlet weak var imageViewOutlet: UIImageView!

    @IBAction func addPictureAction(sender: AnyObject) {
        //let cameraManager = CameraManager()
        //cameraManager.addPreviewLayerToView(self.cameraView)
        let cameraController = SBCameraViewController.init(reviewOptions: SBReviewViewOptions.ShowOfficialButton, initialCaptureType: SBCaptureType.Photo);
        
        cameraController.captureDelegate = self;
        
        //self.presentedViewController(cameraController);
        self.presentViewController(cameraController, animated: true, completion: nil);
        
        /*
        var cameraController = ;
        
        // ===> 1. Init a `SBCameraViewController`
        SBCameraViewController *cameraController = [[SBCameraViewController alloc] initWithReviewOptions:reviewOptions initialCaptureType:SBCaptureTypeVideo];
        
        // ===> 2. Set the `SBCameraViewController's` `delegate`.
        cameraController.captureDelegate = self;
        
        // ===> 3. Present the `SBCameraViewController`.
        [self presentViewController:cameraController animated:YES completion:nil];*/
    }
    
    func cameraControllerCancelled(controller: SBCaptureViewController!) {
        return;
    }
    func reviewController(controller: SBReviewController!, acceptedAsset asset: SBAsset!) {
      //  var signal = asset.fetchImage().;
        //signal. { image in imageViewOutlet.image = image}
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
