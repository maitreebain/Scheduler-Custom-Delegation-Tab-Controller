//
//  PersistenceHelper.swift
//  Scheduler
//
//  Created by Alex Paul on 1/23/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

public enum DataPersistenceError: Error {
  case propertyListEncodingError(Error)
  case propertyListDecodingError(Error)
  case writingError(Error)
  case deletingError
  case noContentsAtPath(String)
}


class DataPersistence {
  
  private let filename: String
  
  private var items: [Event]
      
  public init(filename: String) {
    self.filename = filename
    self.items = []
  }
  
  private func saveItemsToDocumentsDirectory() throws {
    do {
      let url = FileManager.getPath(with: filename, for: .documentsDirectory)
      let data = try PropertyListEncoder().encode(items)
      try data.write(to: url, options: .atomic)
    } catch {
      throw DataPersistenceError.writingError(error)
    }
  }
  
  // Create
  public func createItem(_ item: Event) throws {
    _ = try? loadItems()
    items.append(item)
    do {
      try saveItemsToDocumentsDirectory()
    } catch {
      throw DataPersistenceError.writingError(error)
    }
  }
  
  // Read
  public func loadItems() throws -> [Event] {
    let path = FileManager.getPath(with: filename, for: .documentsDirectory).path
     if FileManager.default.fileExists(atPath: path) {
       if let data = FileManager.default.contents(atPath: path) {
         do {
           items = try PropertyListDecoder().decode([Event].self, from: data)
         } catch {
          throw DataPersistenceError.propertyListDecodingError(error)
         }
       }
     }
    return items
  }
  
  // for re-ordering, and keeping date in sync
  public func synchronize(_ items: [Event]) {
    self.items = items
    try? saveItemsToDocumentsDirectory()
  }
  
  // Update
  
  // Delete
  public func deleteItem(at index: Int) throws {
    items.remove(at: index)
    do {
      try saveItemsToDocumentsDirectory()
    } catch {
      throw DataPersistenceError.deletingError
    }
  }
  
  public func hasItemBeenSaved(_ item: Event) -> Bool {
    guard let items = try? loadItems() else {
      return false
    }
    self.items = items
    if let _ = self.items.firstIndex(of: item) {
      return true
    }
    return false
  }
  
  public func removeAll() {
    guard let loadedItems = try? loadItems() else {
      return
    }
    items = loadedItems
    items.removeAll()
    try? saveItemsToDocumentsDirectory()
  }
}
