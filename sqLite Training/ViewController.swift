//
//  ViewController.swift
//  sqLite Training
//
//  Created by Pooyan J on 11/9/1402 AP.
//

import UIKit
import SQLite

class ViewController: UIViewController {
    
    
    struct User {
        let id: Int
        let name: String
        let email: String
    }
    
    @IBOutlet weak var createTableButton: UIButton!
    @IBOutlet weak var insertUserButton: UIButton!
    @IBOutlet weak var listUsersButton: UIButton!
    @IBOutlet weak var updateUserButton: UIButton!
    @IBOutlet weak var deleteUserButton: UIButton!
    @IBAction func createTableAction(_ sender: Any) {
        createTable()
    }
    @IBAction func inserUserAction(_ sender: Any) {
        addUser()
    }
    @IBAction func listUsersAction(_ sender: Any) {
        getLists()
    }
    @IBAction func updateButtonAction(_ sender: Any) {
        updateUser()
    }
    @IBAction func deleteButtonAction(_ sender: Any) {
        deleteUser()
    }
    var id = Expression<Int>("id")
    let name = Expression<String?>("name")
    var email = Expression<String?>("email")
    var database: Connection!
    let usersTable = Table("users")
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        if let path = getSQLiteFilePath() {
            print("SQLite file path: \(path)")
        } else {
            print("Unable to find SQLite file path.")
        }
    }
}

//MARK: - Setup Views
extension ViewController {
    
    private func setupViews() {
        setupCreateTableButton()
        setupInsertUserButton()
        setupListUsersButton()
        setupUpdateUserButton()
        setupDeleteUserButton()
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentDirectory.appendingPathComponent("users").appendingPathExtension("sqlite3")
            let database = try Connection(fileURL.path)
            self.database = database
        } catch {
            print(error)
        }
    }
    
    private func setupCreateTableButton() {
        createTableButton.setTitle("create table", for: .normal)
    }
    
    private func setupInsertUserButton() {
        insertUserButton.setTitle("insert user", for: .normal)
    }
    
    private func setupListUsersButton() {
        listUsersButton.setTitle("list users", for: .normal)
    }
    
    private func setupUpdateUserButton() {
        updateUserButton.setTitle("update user", for: .normal)
    }
    
    private func setupDeleteUserButton() {
        deleteUserButton.setTitle("delete user", for: .normal)
    }
}

//MARK: - Actions
extension ViewController {
    
    func getSQLiteFilePath() -> String? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let sqliteFileName = "your_database_name.sqlite"
        let sqliteFilePath = documentsDirectory.appendingPathComponent(sqliteFileName)

        return sqliteFilePath.path
    }
    
    private func addUser() {
        showAlertWithTextField(title: "Add", actionTitle: "Add", alertMessage: "") { (name, email) in
            let insertUser = self.usersTable.insert(self.name <- name, self.email <- email)
            do {
                try self.database.run(insertUser)
                print("inserted successfully")
            } catch {
                print(error)
            }
        }
    }
    
    private func getLists() {
        do {
            let users = try database.prepare(usersTable)
            print("USERS ===>",users)
            for user in users {
                print("userID ===> , \(user[self.id]) name ===>, \(user[self.name]) email ===>, \(user[self.email])")
            }
        } catch {
            print(error)
        }
    }
    
    private func deleteUser() {
        showAlertWithOneTextField(title: "Delete", actionTitle: "Delete", alertMessage: "") { id in
            let user = self.usersTable.filter(self.id == id)
            let deleteUser = user.delete()
            do {
               try self.database.run(deleteUser)
                print("user with user id \(id) deleted")
            } catch {
                print(error)
            }
        }
    }
    
    private func updateUser() {
        showAlertWithTextField(title: "Update", actionTitle: "Update", alertMessage: "") { (name, email) in
            let user = self.usersTable.filter(self.name == name)
            let updateUser = user.update(self.email <- email)
            do {
                try self.database.run(updateUser)
            } catch {
               print(error)
            }
        }
    }
    
    private func showAlertWithTextField(title: String, actionTitle: String, alertMessage: String, completion: @escaping ((String, String))->()) {
        let alert = UIAlertController(title: title, message: alertMessage, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = "Name"
        }
        alert.addTextField { textfield in
            textfield.placeholder = "Email"
        }
        let action = UIAlertAction(title: "Submit", style: .default) { _ in
            guard let name = alert.textFields?.first, let email = alert.textFields?.last else { return }
            print("NAME =>", name)
            print("EMAIL =>", email)
            completion((name.text!, email.text!))
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func showAlertWithOneTextField(title: String, actionTitle: String, alertMessage: String, completion: @escaping (Int)->()) {
        let alert = UIAlertController(title: title, message: alertMessage, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = "UserID"
        }
        let action = UIAlertAction(title: "Submit", style: .default) { _ in
            guard let id = Int((alert.textFields?.first?.text)!) else { return }
            print("user id =>", id )
            completion(id)
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func createTable() {
        let table = usersTable.create { table in
            table.column(id, primaryKey: true)
            table.column(name)
            table.column(email, unique: true)
        }
        do {
            try database.run(table)
            print("table created")
        } catch {
            print(error)
        }
    }
    
}
