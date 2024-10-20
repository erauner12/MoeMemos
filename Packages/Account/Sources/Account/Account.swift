//
//  Account.swift
//  
//
//  Created by Mudkip on 2023/11/12.
//

import Foundation
import Models
import KeychainSwift
import MemosV0Service
import MemosV1Service
import os

public extension Account {
    private static let logger = Logger(subsystem: "me.erauner.MoeMemos", category: "Account")
    
    private static var keychain: KeychainSwift {
        let keychain = KeychainSwift()
        keychain.accessGroup = AppInfo.keychainAccessGroupName
        return keychain
    }
    
    func save() throws {
        let data = try JSONEncoder().encode(self)
        Self.keychain.set(data, forKey: key, withAccess: .accessibleAfterFirstUnlock)
        Self.logger.info("Account saved with key: \(self.key)")
    }
    
    func delete() {
        Self.keychain.delete(key)
        Self.logger.info("Account deleted with key: \(self.key)")
    }
    
    static func retriveAll() -> [Account] {
        let keychain = Self.keychain
        let decoder = JSONDecoder()
        let keys = keychain.allKeys
        var accounts = [Account]()
        
        for key in keys {
            if let data = keychain.getData(key), let account = try? decoder.decode(Account.self, from: data) {
                accounts.append(account)
                Self.logger.info("Retrieved account with key: \(key)")
            } else {
                Self.logger.error("Failed to retrieve account with key: \(key)")
            }
        }
        Self.logger.info("Retrieved \(accounts.count) accounts")
        return accounts
    }
    
    func remoteService() -> RemoteService? {
        if case .memosV0(host: let host, id: _, accessToken: let accessToken) = self, let hostURL = URL(string: host) {
            return MemosV0Service(hostURL: hostURL, accessToken: accessToken)
        }
        if case .memosV1(host: let host, id: let userId, accessToken: let accessToken) = self, let hostURL = URL(string: host) {
            return MemosV1Service(hostURL: hostURL, accessToken: accessToken, userId: userId)
        }
        return nil
    }
    
    @MainActor
    func toUser() async throws -> User {
        if case .local = self {
            return User(accountKey: key, nickname: NSLocalizedString("account.local-user", comment: ""))
        }
        if let remoteService = remoteService() {
            return try await remoteService.getCurrentUser()
        }
        throw MoeMemosError.notLogin
    }
}
