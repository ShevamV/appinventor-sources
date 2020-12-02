// -*- mode: swift; swift-mode:basic-offset: 2; -*-
// Copyright © 2016-2020 Massachusetts Institute of Technology, All rights reserved.

import Foundation
import CoreData
import SQLite

open class TinyDB: NonvisibleComponent {

  fileprivate var _database: Connection!
  fileprivate var _table = Table("TinyDB1")
  fileprivate let _key = Expression<String>("_key")
  fileprivate let _value = Expression<String>("_value")
  private var _namespace = "TinyDB1"

  public override init(_ parent: ComponentContainer) {
    let assetmgr = parent.form?.application?.assetManager
    let sqlitedb = (assetmgr?.pathForPrivateAsset("TinyDb1.sqlite"))!
    do {
      _database = try? Connection(sqlitedb)
    }
    super.init(parent)
    do {
      _ = try? _database.run(_table.create(ifNotExists: true) { t in
        t.column(_key, primaryKey: true)
        t.column(_value)
      })
    }
  }

  /// MARK: TinyDB Properties

  @objc open var Namespace: String {
    get {
      return _namespace
    }
    set (namespace) {
      do {
        let new_table = Table(namespace)
        _ = try? _database.run(new_table.create(ifNotExists: true) { t in
          t.column(_key, primaryKey: true)
          t.column(_value)
        })
        _table = new_table
        _namespace = namespace
      }
    }
  }

  /// MARK: TinyDB Methods

  @objc open func StoreValue(_ tag: String, _ valueToStore: AnyObject) {
    do {
      let valueAsString = try getJsonRepresentation(valueToStore)
      _ = try _database.run(_table.insert(or: .replace, _key <- tag, _value <- valueAsString))
    } catch {
      NSLog("Unable to write to TinyDB")
    }
  }

  @objc open func GetValue(_ tag: String, _ valueIfTagNotThere: AnyObject) -> AnyObject {
    do {
      if let value = try _database.pluck(_table.select(_value).filter(_key == tag)),
        let result = try getObjectFromJson(value[_value]) {
          return result
      }
    } catch {
      NSLog("Unable to read value from TinyDB")
    }
    return valueIfTagNotThere
  }

  @objc open func GetTags() -> [String] {
    var result: [String] = []
    do {
      for tag in try _database.prepare(_table.select(_key)) {
        result.append(tag[_key])
      }
    } catch {
      NSLog("Unable to read tags from TinyDB")
    }
    return result
  }

  @objc open func ClearAll() {
    do {
      _ = try _database.run(_table.delete())
    } catch {
      NSLog("Unable to clear all tags")
    }
  }

  @objc open func ClearTag(_ tag: String) {
    do {
      _ = try _database.run(_table.filter(_key == tag).delete())
    } catch {
      NSLog("Unable to clear tag from TinyDB")
    }
  }
}
