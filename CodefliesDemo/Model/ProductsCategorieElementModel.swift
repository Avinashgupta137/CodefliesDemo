//
//  ProductsCategorieElementModel.swift
//  CodefliesDemo
//
//  Created by Avinash Gupta on 31/03/25.
//

import Foundation

// MARK: - ProductsCategorieElement
struct ProductsCategorieElement: Codable {
    let id: Int
    let name, slug: String
    let parent: Int
    let description: String
    let display: Display
    let image: Image?
    let menuOrder, count: Int
    let yoastHead: String
    let yoastHeadJSON: YoastHeadJSON
    let links: Links

    enum CodingKeys: String, CodingKey {
        case id, name, slug, parent, description, display, image
        case menuOrder = "menu_order"
        case count
        case yoastHead = "yoast_head"
        case yoastHeadJSON = "yoast_head_json"
        case links = "_links"
    }
}

enum Display: String, Codable {
    case displayDefault = "default"
}

// MARK: - Image
struct Image: Codable {
    let id: Int
    let dateCreated, dateCreatedGmt, dateModified, dateModifiedGmt: String
    let src: String
    let name, alt: String

    enum CodingKeys: String, CodingKey {
        case id
        case dateCreated = "date_created"
        case dateCreatedGmt = "date_created_gmt"
        case dateModified = "date_modified"
        case dateModifiedGmt = "date_modified_gmt"
        case src, name, alt
    }
}

// MARK: - Links
struct Links: Codable {
    let linksSelf: [SelfElement]
    let collection: [Collection]

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case collection
    }
}

// MARK: - Collection
struct Collection: Codable {
    let href: String
}

// MARK: - SelfElement
struct SelfElement: Codable {
    let href: String
    let targetHints: TargetHints
}

// MARK: - TargetHints
struct TargetHints: Codable {
    let allow: [Allow]
}

enum Allow: String, Codable {
    case allowGET = "GET"
    case delete = "DELETE"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}

// MARK: - YoastHeadJSON
struct YoastHeadJSON: Codable {
    let title: String
    let robots: Robots
    let canonical: String
    let ogLocale: OgLocale
    let ogType: OgType
    let ogTitle: String
    let ogURL: String
    let twitterCard: TwitterCard
    let schema: Schema

    enum CodingKeys: String, CodingKey {
        case title, robots, canonical
        case ogLocale = "og_locale"
        case ogType = "og_type"
        case ogTitle = "og_title"
        case ogURL = "og_url"
        case twitterCard = "twitter_card"
        case schema
    }
}

enum OgLocale: String, Codable {
    case frFR = "fr_FR"
}

enum OgType: String, Codable {
    case article = "article"
}

// MARK: - Robots
struct Robots: Codable {
    let index: Index
    let follow: Follow
    let maxSnippet: MaxSnippet
    let maxImagePreview: MaxImagePreview
    let maxVideoPreview: MaxVideoPreview

    enum CodingKeys: String, CodingKey {
        case index, follow
        case maxSnippet = "max-snippet"
        case maxImagePreview = "max-image-preview"
        case maxVideoPreview = "max-video-preview"
    }
}

enum Follow: String, Codable {
    case follow = "follow"
}

enum Index: String, Codable {
    case index = "index"
}

enum MaxImagePreview: String, Codable {
    case maxImagePreviewLarge = "max-image-preview:large"
}

enum MaxSnippet: String, Codable {
    case maxSnippet1 = "max-snippet:-1"
}

enum MaxVideoPreview: String, Codable {
    case maxVideoPreview1 = "max-video-preview:-1"
}

// MARK: - Schema
struct Schema: Codable {
    let context: String
    let graph: [Graph]

    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case graph = "@graph"
    }
}

// MARK: - Graph
struct Graph: Codable {
    let type: GraphType
    let id: String
    let url: String?
    let name: String?
    let isPartOf, breadcrumb: Breadcrumb?
    let inLanguage: InLanguage?
    let itemListElement: [ItemListElement]?
    let description: Description?
    let publisher: Breadcrumb?
    let potentialAction: [PotentialAction]?
    let logo: Logo?
    let image: Breadcrumb?
    let sameAs: [String]?

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case id = "@id"
        case url, name, isPartOf, breadcrumb, inLanguage, itemListElement, description, publisher, potentialAction, logo, image, sameAs
    }
}

// MARK: - Breadcrumb
struct Breadcrumb: Codable {
    let id: String

    enum CodingKeys: String, CodingKey {
        case id = "@id"
    }
}

enum Description: String, Codable {
    case collectionDePrêtÀPorterÉlégantFéminin = "Collection de prêt-à-porter élégant féminin"
}

enum InLanguage: String, Codable {
    case frFR = "fr-FR"
}

// MARK: - ItemListElement
struct ItemListElement: Codable {
    let type: ItemListElementType
    let position: Int
    let name: String
    let item: String?

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case position, name, item
    }
}

enum ItemListElementType: String, Codable {
    case listItem = "ListItem"
}

// MARK: - Logo
struct Logo: Codable {
    let type: LogoType
    let inLanguage: InLanguage
    let id: String
    let url, contentURL: String
    let width, height: Int
    let caption: Caption

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case inLanguage
        case id = "@id"
        case url
        case contentURL = "contentUrl"
        case width, height, caption
    }
}

enum Caption: String, Codable {
    case alniya = "ALNIYA"
}

enum LogoType: String, Codable {
    case imageObject = "ImageObject"
}

// MARK: - PotentialAction
struct PotentialAction: Codable {
    let type: PotentialActionType
    let target: Target
    let queryInput: QueryInput

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case target
        case queryInput = "query-input"
    }
}

// MARK: - QueryInput
struct QueryInput: Codable {
    let type: QueryInputType
    let valueRequired: Bool
    let valueName: ValueName

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case valueRequired, valueName
    }
}

enum QueryInputType: String, Codable {
    case propertyValueSpecification = "PropertyValueSpecification"
}

enum ValueName: String, Codable {
    case searchTermString = "search_term_string"
}

// MARK: - Target
struct Target: Codable {
    let type: TargetType
    let urlTemplate: URLTemplate

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case urlTemplate
    }
}

enum TargetType: String, Codable {
    case entryPoint = "EntryPoint"
}

enum URLTemplate: String, Codable {
    case httpsAlniyaparisCOMSSearchTermString = "https://alniyaparis.com/?s={search_term_string}"
}

enum PotentialActionType: String, Codable {
    case searchAction = "SearchAction"
}

enum GraphType: String, Codable {
    case breadcrumbList = "BreadcrumbList"
    case collectionPage = "CollectionPage"
    case organization = "Organization"
    case webSite = "WebSite"
}

enum TwitterCard: String, Codable {
    case summaryLargeImage = "summary_large_image"
}

typealias ProductsCategorie = [ProductsCategorieElement]
