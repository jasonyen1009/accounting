//
//  AddIncomeTableViewController.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/8/10.
//

import UIKit

protocol AddIncomeTableViewControllerDelegate: AddIncomeTableViewController {
    func addIncomeTableViewController(_ controller: AddIncomeTableViewController, didEdit data: Income)
}

class AddIncomeTableViewController: UITableViewController {
    
    var mydata: Income?
    var number1 = 0.0
    var number2 = 0.0
    var calculatetype = ""
    
    // date
    var now = Date()
    let formatter = DateFormatter()
    var delegate: AddIncomeTableViewControllerDelegate?

    @IBOutlet weak var categorySegmentedcontrol: UISegmentedControl!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var accountsSegmentedcontrol: UISegmentedControl!
    @IBOutlet weak var accountImagview: UIImageView!
    @IBOutlet weak var incomenameTextfield: UITextField!
    @IBOutlet weak var incomeTextfield: UITextField!
    @IBOutlet weak var noteTextview: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // textfield delegate
        incomeTextfield.delegate = self
        incomenameTextfield.delegate = self
        // textview delegate
        noteTextview.delegate = self
        
        noteTextview.text = "備忘錄"
        noteTextview.textColor = UIColor.lightGray

        // custom keyboard
        let keyboardView = Keyboard(frame: CGRect(x: 0, y: 0, width: 0, height: (view.frame.height) * 2 / 6))
        keyboardView.delegate = self
        
        //
        incomeTextfield.inputView = keyboardView
        
        
    }
    
    //收鍵盤
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    @IBAction func changeincomeimage(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            accountImagview.image = UIImage(named: "salary")
        case 1:
            accountImagview.image = UIImage(named: "interest")
        case 2:
            accountImagview.image = UIImage(named: "invest")
        case 3:
            accountImagview.image = UIImage(named: "rent")
        case 4:
            accountImagview.image = UIImage(named: "transaction")
        default :
            accountImagview.image = UIImage(named: "game")
            
        }
    }
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddIncomeTableViewController: KeyboardDelegate {
    
    func keyWasTapped(character: String) {
        incomeTextfield.insertText(character)
    }
    
    func deletTapped() {
        incomeTextfield.deleteBackward()
        
    }
    
    func deletAllTapped() {
        incomeTextfield.text?.removeAll()
        
    }
    
    func plusTapped() {
        if let number = incomeTextfield.text {
            number1 = Double(number) ?? 0
            incomeTextfield.text?.removeAll()
        }
        calculatetype = "+"
    }
    
    func multiplicationTapped() {
        if let number = incomeTextfield.text {
            number1 = Double(number) ?? 0
            incomeTextfield.text?.removeAll()
        }
        calculatetype = "X"
    }
    
    func deductTapped() {
        if let number = incomeTextfield.text {
            number1 = Double(number) ?? 0
            incomeTextfield.text?.removeAll()
        }
        calculatetype = "-"
    }
    
    func divisionTapped() {
        if let number = incomeTextfield.text {
            number1 = Double(number) ?? 0
            incomeTextfield.text?.removeAll()
        }
        calculatetype = "/"
    }
    
    func calculateTapped() {
        if let number = incomeTextfield.text {
            number2 = Double(number) ?? 0
            switch calculatetype{
            case "+":
                incomeTextfield.text = String(number1 + number2)
            case "X":
                incomeTextfield.text = String(number1 *  number2)
            case "-":
                incomeTextfield.text = String(number1 -  number2)
            case "/":
                incomeTextfield.text = String(number1 /  number2)
            default :
                print("")
            }
            number1 = 0.0
            number2 = 0.0
        }
        dismissKeyBoard()
        
    }
}



extension AddIncomeTableViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if noteTextview.textColor == UIColor.lightGray {
            noteTextview.text = nil
            noteTextview.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if noteTextview.text.isEmpty {
            noteTextview.textColor = UIColor.lightGray
        }
    }

}


extension AddIncomeTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        incomeTextfield.becomeFirstResponder()
        return true
    }
    
}
