#if canImport(SwiftSyntax600)
import SharedTypes
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

internal extension DeclModifierListSyntax {
    var isStatic: Bool {
        return contains {
            return $0.name.tokenKind == .keyword(.static)
                || $0.name.tokenKind == .keyword(.class)
        }
    }

    var isPrivate: Bool {
        return contains {
            return $0.name.tokenKind == .keyword(.private)
                || $0.name.tokenKind == .keyword(.fileprivate)
        }
    }

    func filterPrivate() -> DeclModifierListSyntax {
        return filter {
            return $0.name.tokenKind != .keyword(.private)
        }
    }

    func filterFinal() -> DeclModifierListSyntax {
        return filter {
            return $0.name.tokenKind != .keyword(.final)
        }
    }
}

internal extension FunctionSignatureSyntax {
    /// The `Spryable` entry point that matches this signature's effects.
    ///
    /// `rethrows` keeps `spryify`, because a `rethrows` function may not call an
    /// unconditionally throwing one.
    func spryifyCallee() throws -> (name: String, needsTry: Bool) {
        guard let throwsClause = effectSpecifiers?.throwsClause else {
            return ("spryify", false)
        }

        if throwsClause.type != nil {
            throw SpryableDiagnostic.typedThrowsNotSupported
        }

        guard throwsClause.throwsSpecifier.tokenKind == .keyword(.throws) else {
            return ("spryify", false)
        }

        return ("spryifyThrows", true)
    }
}

internal extension VariableDeclSyntax {
    var binding: PatternBindingSyntax {
        get throws {
            guard let binding = bindings.first else {
                throw SpryableDiagnostic.invalidVariableRequirement
            }

            return binding
        }
    }
}

internal extension MemberAccessExprSyntax {
    var varKeyword: VarKeyword? {
        guard let name = declName.baseName.identifier?.name else {
            return nil
        }

        return .init(rawValue: name)
    }

    var funcKeyword: FuncKeyword? {
        guard let name = declName.baseName.identifier?.name else {
            return nil
        }

        return .init(rawValue: name)
    }
}

internal extension VariableDeclSyntax {
    var options: [VarKeyword] {
        var options: [VarKeyword] = attributes.flatMap { attr in
            attr.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self).map { args in
                args.compactMap { arg in
                    arg.expression.as(MemberAccessExprSyntax.self)?.varKeyword
                }
            } ?? []
        }

        if !(options ~= .get) {
            options.append(.get)
        }

        return options
    }
}

internal extension AttributeSyntax {
    var varOptions: [VarKeyword] {
        var options = arguments?.as(LabeledExprListSyntax.self)?.compactMap { expr in
            expr.expression.as(MemberAccessExprSyntax.self)?.varKeyword
        } ?? []

        if !(options ~= .get) {
            options.append(.get)
        }

        return options
    }

    var funcOptions: [FuncKeyword] {
        var options = arguments?.as(LabeledExprListSyntax.self)?.compactMap { expr in
            expr.expression.as(MemberAccessExprSyntax.self)?.funcKeyword
        } ?? []

        if options.isEmpty {
            options.append(.asRealClosure)
        }

        return options
    }
}

internal extension FunctionParameterSyntax {
    var isClosure: Bool {
        return isNonEscapingClosure || isEscapingClosure
    }

    var isEscapingClosure: Bool {
        return type.as(AttributedTypeSyntax.self)?.attributes.contains(where: { elem in
            return elem.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.tokenKind == .identifier("escaping")
        }) == true
    }

    var isNonEscapingClosure: Bool {
        return type.as(FunctionTypeSyntax.self) != nil
    }
}

internal extension Macro {
    static func enumBlockBuilder(_ requirements: MembersParser, isStatic: Bool) throws -> EnumDeclSyntax {
        let declarations = try enumCaseDeclarations(requirements, isStatic: isStatic)
        let members: MemberBlockItemListSyntax =
            if declarations.isEmpty {
                MemberBlockItemListSyntax {
                    let caseName: String = "_unknown_"
                    let caseEl = EnumCaseElementSyntax(name: .identifier(caseName), rawValue: .init(value: StringLiteralExprSyntax(content: "'enum' must have at least one 'case'")))
                    let elements: EnumCaseElementListSyntax = .init(arrayLiteral: caseEl)
                    EnumCaseDeclSyntax(elements: elements)
                }
            } else {
                MemberBlockItemListSyntax {
                    for enumCase in declarations {
                        enumCase
                    }
                }
            }

        let inheritanceEnumClause = InheritanceClauseSyntax {
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "String"))
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "StringRepresentable"))
        }

        return EnumDeclSyntax(modifiers: requirements.syntax.modifiers.filterPrivate().filterFinal(),
                              name: isStatic ? "ClassFunction" : "Function",
                              inheritanceClause: inheritanceEnumClause,
                              memberBlock: MemberBlockSyntax(members: members))
    }

    private static func enumCaseDeclarations(_ requirements: MembersParser, isStatic: Bool) throws -> [EnumCaseDeclSyntax] {
        var cases = [EnumCaseDeclSyntax]()
        for variable in requirements.variables {
            guard variable.modifiers.isStatic == isStatic else {
                continue
            }

            let options = variable.options
            let caseName: String = try variable.binding.pattern.trimmedDescription

            let addCase: (_ sub: String?) -> Void = { sub in
                let caseEl: EnumCaseElementSyntax =
                    if let sub {
                        .init(name: .identifier(caseName + sub),
                              rawValue: .init(value: StringLiteralExprSyntax(content: caseName + sub)))
                    } else {
                        .init(name: .identifier(caseName))
                    }

                let elements: EnumCaseElementListSyntax = .init(arrayLiteral: caseEl)
                let enumCase = EnumCaseDeclSyntax(elements: elements)
                cases.append(enumCase)
            }

            if options ~= .set {
                addCase("_get")
                addCase("_set")
            } else {
                addCase(nil)
            }
        }

        for function in requirements.functions {
            guard function.modifiers.isStatic == isStatic else {
                continue
            }

            let caseName = function.name.text
            let nameParameters: [String] = function.signature.parameterClause.parameters.enumerated().map { idx, param in
                var name: [String] = []
                if param.firstName.trimmed.text == TokenSyntax.wildcardToken().text {
                    if let secondName = param.secondName?.trimmed,
                       secondName.text != TokenSyntax.wildcardToken().text {
                        name.append(secondName.text.capitalized)
                    } else {
                        name.append("Arg\(idx)")
                    }
                } else {
                    name.append(param.firstName.trimmed.text.capitalized)
                }

                return name.joined(separator: "_")
            }
            let name = nameParameters.isEmpty ? caseName : caseName.description + "With" + nameParameters.joined(separator: "_")
            let rawParameters = function.signature
                .parameterClause
                .parameters
                .map { param in
                    param.firstName.trimmedDescription + ":"
                }
                .joined()

            let rawValue = caseName + "(" + rawParameters + ")"

            let caseEl: EnumCaseElementSyntax
            caseEl = EnumCaseElementSyntax(name: .identifier(name),
                                           rawValue: InitializerClauseSyntax(value: StringLiteralExprSyntax(content: rawValue)))
            let elements: EnumCaseElementListSyntax = .init(arrayLiteral: caseEl)
            let enumCase = EnumCaseDeclSyntax(elements: elements)
            cases.append(enumCase)
        }

        var uniqRawValues: Set<String> = []
        var uniqNames: Set<String> = []
        var uniq: [EnumCaseDeclSyntax] = []
        for enumCaseDeclSyntax in cases {
            guard let element = enumCaseDeclSyntax.elements.first else {
                continue
            }

            if let rawValue = element.rawValue?.value.description,
               !uniqRawValues.insert(rawValue).inserted {
                continue
            }

            guard uniqNames.insert(element.name.text).inserted else {
                throw SpryableDiagnostic.duplicateCaseName(element.name.text)
            }

            uniq.append(enumCaseDeclSyntax)
        }
        return uniq
    }
}
#endif
