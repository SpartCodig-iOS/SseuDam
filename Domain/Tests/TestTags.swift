//
//  TestTags.swift
//  DomainTests
//
//  Created by Wonji Suh on 12/05/24.
//

import Testing

// Common tags used across Domain test suites for easy filtering
extension Tag {
    @Tag static var unit: Self
    @Tag static var useCase: Self
    @Tag static var integration: Self
    
}
