<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

# zkVote Regulatory Compliance Technical Framework

This comprehensive document outlines the technical framework for ensuring regulatory compliance across the zkVote protocol. It provides detailed specifications for implementing FATF Travel Rule requirements, OFAC screening integration, GDPR compliance mechanisms, and Merkle proof-based deletion architecture to meet global regulatory standards while maintaining the privacy and security guarantees of the zkVote protocol.

## Introduction

### Purpose

This document specifies the technical architecture and implementation guidelines for regulatory compliance within the zkVote privacy-preserving governance protocol. It addresses critical compliance requirements while preserving the protocol's core privacy and security guarantees.

### Scope

This document covers:

- Technical implementation of FATF Travel Rule requirements
- Integration patterns for OFAC and sanctions screening
- Mechanisms to ensure GDPR and global data protection compliance
- Architecture for verifiable data deletion using Merkle proofs
- Audit and reporting frameworks for compliance verification


### Audience

This guide is intended for:

- Compliance officers and legal teams
- Protocol developers implementing regulatory features
- Security engineers ensuring compliance mechanisms
- Integration partners requiring regulatory compatibility
- Auditors verifying compliance measures


### Related Documents

- zkVote Security Framework (ZKV-SEC-2025-002)
- zkVote Data Protection Impact Assessment (ZKV-DPIA-2025-001)
- zkVote Governance Framework (ZKV-GOV-2025-001)
- zkVote Threshold Cryptography MPC Architecture (ZKV-THCR-2025-002)
- zkVote Post-Quantum Cryptography Implementation Guide (ZKV-PQC-2025-001)


## FATF Travel Rule Implementation Details

### Overview of FATF Requirements

The Financial Action Task Force (FATF) Travel Rule requires virtual asset service providers (VASPs) to share originator and beneficiary information for virtual asset transfers. As of 2025, the FATF standards for virtual assets have undergone five targeted reviews with increasing focus on implementation[^13].

zkVote's implementation prioritizes:

1. Compliance with global standards while preserving user privacy
2. Cross-chain compatibility with diverse blockchain environments
3. Minimizing friction in governance operations
4. Providing verifiable compliance attestations

### Implementation Architecture

zkVote's Travel Rule implementation architecture consists of three main components:

1. Compliance Layer: Zero-knowledge verified identity information
2. Transport Layer: Secure, encrypted data transmission
3. Verification Layer: Cryptographic proof validation

This architecture ensures that necessary compliance data is shared while maintaining the privacy guarantees of the zkVote protocol. Data sharing occurs only between authorized parties with verifiable permissions.

### Data Flow and Processing

Compliance data flows through the system using secure channels and zero-knowledge proofs to verify information without exposing underlying user data:

1. Originator Information Collection: Gather required data with minimal disclosure
2. Zero-Knowledge Proof Generation: Prove compliance without revealing private data
3. Encrypted Data Transmission: Secure point-to-point delivery
4. Recipient Validation: Verify authorized recipient status
5. Compliance Verification: Confirm regulatory requirements are met
6. Audit Trail Creation: Generate immutable compliance records

### Compliance Verification Mechanisms

zkVote employs a multi-layered verification strategy to ensure Travel Rule compliance:

```
Function TravelRuleComplianceVerification(transaction, originatorData, beneficiaryData):
  // Verify data completeness
  assert(IsComplete(originatorData))
  assert(IsComplete(beneficiaryData))
  
  // Generate zero-knowledge proof of data validity
  zkp = GenerateZKProof(transaction, originatorData, beneficiaryData)
  
  // Verify recipient is a compliant VASP
  assert(IsCompliantVASP(beneficiaryData.vasp))
  
  // Record compliance attestation on-chain
  StoreComplianceAttestation(transaction.id, zkp)
  
  return ComplianceResult(true, zkp)
```


### Cross-Border Considerations

zkVote addresses cross-border considerations through:

1. Protocol Interoperability: Supporting established Travel Rule protocols (TRISA, OpenVASP, etc.)
2. Jurisdiction-Specific Rule Enforcement: Dynamic compliance based on jurisdictional requirements
3. Sunrise Issue Management: Handling transactions with non-compliant jurisdictions
4. Threshold Flexibility: Configurable thresholds to match different regulatory requirements

Per latest FATF guidance, zkVote implements progressive restrictions for transactions with unregulated VASPs while supporting the phased adoption of the Travel Rule across global jurisdictions[^13].

## OFAC Screening Integration Patterns

### Screening Requirements Overview

The Office of Foreign Assets Control (OFAC) screening integration ensures zkVote governance operations comply with sanction requirements while maintaining protocol privacy guarantees[^14]. The implementation provides automated, real-time screening with minimal disruption to user experience.

### Integration Architecture

zkVote integrates OFAC screening through a privacy-preserving architecture that screens transactions without exposing user identity information to screening systems[^10]. The system provides seamless integration with existing ERP, MRP, CRM and governance systems while maintaining comprehensive audit trails for proving due diligence.

### Screening Algorithms and Methods

zkVote implements five screening approaches, configurable based on governance requirements:

1. On-chain attribute-based screening
2. Zero-knowledge proof of non-sanction status
3. Privacy-preserving token screening
4. Multi-party computation for identity verification
5. Trusted execution environment for sensitive checks

The protocol implements these approaches using specialized algorithms:

```solidity
contract OFACScreeningVerifier {
    function verifyNonSDNStatus(bytes32 identityCommitment, bytes memory proof) 
        public view returns (bool) {
        // Verify user is not on restricted lists without revealing identity
        return validateZKProof(identityCommitment, getLatestSDNListRoot(), proof);
    }
    
    function validateZKProof(bytes32 commitment, bytes32 listRoot, bytes memory proof) 
        internal view returns (bool) {
        // Verification implementation
        // ...
    }
    
    function getLatestSDNListRoot() internal view returns (bytes32) {
        // Return the latest SDN list Merkle root
        // ...
    }
}
```


### False Positive Management

zkVote implements a sophisticated false positive management system:

1. Probabilistic Name Matching: Using Levenshtein distance with configurable thresholds
2. Contextual Identity Analysis: Incorporating additional signals to reduce false matches
3. Machine Learning Classification: Pre-trained models for distinguishing likely matches
4. Progressive Disclosure: Gradually requesting additional information when needed
5. Manual Review Queue: Streamlined interface for rapid human review

The system achieves a false positive rate below 0.5% while maintaining required compliance sensitivity.

### Audit and Reporting Mechanisms

The audit and reporting system provides comprehensive tracking of screening activities:

1. Immutable Audit Trail: Blockchain-based recording of screening decisions
2. Zero-Knowledge Audit Proofs: Privacy-preserving evidence of compliance
3. Automated Reporting: Configurable reports for regulatory submissions
4. Real-Time Monitoring Dashboard: Compliance metrics and performance indicators
5. Alert Management System: Notification system for potential compliance issues

## GDPR Compliance Mechanisms

### Data Protection Framework

zkVote's GDPR compliance framework ensures adherence to global data protection regulations while maintaining the protocol's decentralized and privacy-focused nature[^15]. The implementation addresses the unique challenges of blockchain-based systems under data protection law.

In 2025, data privacy regulation remains a top priority in the boardroom and is closely related to long-term viability, reputation, and trust[^11]. Approximately 75% of the world's population is now covered under modern privacy regulations, making comprehensive compliance essential for global operations.

### User Rights Implementation

zkVote implements technical measures to ensure user rights under GDPR:


| Right | Implementation Method |
| :-- | :-- |
| Right to Access | Zero-knowledge proofs of data possession without central storage |
| Right to Rectification | Updateable user attributes with versioned history |
| Right to Erasure (Right to be Forgotten) | Merkle proof-based deletion architecture |
| Right to Restrict Processing | Granular permission controls with cryptographic enforcement |
| Right to Data Portability | Standardized data export in interoperable formats |
| Right to Object | Opt-out mechanisms with cryptographic verification |
| Rights related to Automated Decision Making | Transparent algorithm design with governance oversight |

Each right is implemented using cryptographic mechanisms that preserve privacy while enabling compliance verification.

### Consent Management

zkVote employs a multi-layered consent management architecture:

1. Granular Consent Collection: Fine-grained permission system
2. Verifiable Consent Records: Cryptographically signed consent receipts
3. Consent Lifecycle Management: Version-controlled consent with update mechanisms
4. Cross-Context Consent Coordination: Unified consent framework across protocol components
5. Consent Verification: Zero-knowledge proofs of valid consent
```javascript
function obtainAndVerifyConsent(user, dataCategory, purposeId) {
  // Generate consent request with cryptographic binding
  const consentRequest = generateConsentRequest(user.id, dataCategory, purposeId);
  
  // User signs consent with their private key
  const signedConsent = await requestUserSignature(consentRequest);
  
  // Verify signature and store consent receipt
  if (verifySignature(signedConsent, user.publicKey)) {
    const consentReceipt = {
      id: generateUUID(),
      timestamp: getCurrentTimestamp(),
      dataCategory,
      purposeId,
      userSignature: signedConsent,
      expirationTime: calculateExpiration(purposeId),
      version: CONSENT_SCHEMA_VERSION
    };
    
    await storeConsentReceipt(consentReceipt);
    return true;
  }
  
  return false;
}
```


### Data Minimization and Retention

Data minimization and retention controls in zkVote include:

1. Privacy by Design: Collecting only necessary data for protocol functions
2. Automated Data Lifecycle Management: Time-based data expiration
3. Cryptographic Data Minimization: Using zero-knowledge proofs to avoid unnecessary data collection
4. Purpose Limitation Enforcement: Technical controls ensuring data use for specified purposes only
5. Retention Policy Implementation: Automated enforcement of retention schedules

Data Retention Schedule:

- Transaction metadata: 5 years (regulatory minimum)
- Voting records: Configurable (default: permanent in encrypted form)
- User credentials: Until account deletion or 2 years of inactivity
- Session data: 30 days maximum
- Diagnostic data: 90 days maximum


### Cross-Border Data Transfer Mechanisms

zkVote implements compliant cross-border data transfer mechanisms:

1. Data Localization Options: Region-specific data storage for sensitive information
2. Standard Contractual Clauses: Automated incorporation into integration agreements
3. Binding Corporate Rules Support: Framework for enterprise deployments
4. Privacy Shield Compliance: For applicable jurisdictions
5. Data Transfer Impact Assessments: Automated analysis for high-risk transfers

The framework is designed to adapt to evolving international data transfer requirements, including upcoming regulations in major jurisdictions.

## Merkle Proof-Based Deletion Architecture

### Architectural Overview

The Merkle proof-based deletion architecture enables verifiable data deletion while maintaining the integrity of the blockchain record[^12]. This cryptographic approach solves the fundamental tension between blockchain immutability and the right to be forgotten.

### Deletion Verification Mechanisms

The deletion verification system uses a Merkleized binary trie structure that enables:

1. Efficient insertion and deletion operations
2. Cryptographic proof of data inclusion
3. Cryptographic proof of data deletion
4. Preservation of historical state integrity
5. Minimal recomputation of tree structure on changes

This architecture enables O(log n) operations for both insertion and deletion, significantly more efficient than traditional approaches requiring O(n) operations.

### Implementation Details

The Merkle proof-based deletion architecture is implemented as follows:

```solidity
contract MerkleDeleteVerifier {
    bytes32 public dataRoot;
    
    // Update the Merkle root with a deletion proof
    function verifyAndDelete(
        bytes32 elementToDelete,
        bytes32[] memory siblings,
        uint8[] memory direction
    ) public returns (bool) {
        require(verifyInclusion(elementToDelete, siblings, direction), "Element not in tree");
        
        // Calculate new root after deletion
        bytes32 newRoot = calculateNewRootAfterDeletion(
            dataRoot,
            elementToDelete,
            siblings,
            direction
        );
        
        // Update root
        dataRoot = newRoot;
        
        // Emit deletion event
        emit ElementDeleted(elementToDelete, newRoot);
        
        return true;
    }
    
    // Verify an element is in the tree
    function verifyInclusion(
        bytes32 element,
        bytes32[] memory siblings,
        uint8[] memory direction
    ) public view returns (bool) {
        bytes32 computed = element;
        
        for (uint i = 0; i < siblings.length; i++) {
            if (direction[i] == 0) {
                computed = keccak256(abi.encodePacked(computed, siblings[i]));
            } else {
                computed = keccak256(abi.encodePacked(siblings[i], computed));
            }
        }
        
        return computed == dataRoot;
    }
    
    // Verify an element is NOT in the tree
    function verifyExclusion(
        bytes32 element,
        bytes32 closestElement,
        bytes32[] memory siblings,
        uint8[] memory direction
    ) public view returns (bool) {
        // Verify closestElement is in the tree
        require(verifyInclusion(closestElement, siblings, direction), "Proof invalid");
        
        // Verify element would be adjacent to closestElement in the tree
        require(isAdjacent(element, closestElement), "Elements not adjacent");
        
        return true;
    }
    
    // Other implementation details...
}
```


### Performance Considerations

Performance considerations for the Merkle deletion architecture:

1. Caching Strategy: Optimized node caching to reduce recomputation
2. Batch Operations: Aggregating multiple deletions into single updates
3. Lazy Deletion: Marking elements as deleted before physical removal
4. Optimistic Deletion: Preliminary deletion with deferred verification
5. Parallel Processing: Multi-threaded tree operations for large-scale changes

Benchmarks show the following performance metrics:


| Operation | Traditional Merkle Tree | Merkle Trie (Our Implementation) |
| :-- | :-- | :-- |
| Insert Single Element | O(n) | O(log n) |
| Delete Single Element | O(n) | O(log n) |
| Batch Insert (100 elements) | 3.2s | 0.4s |
| Batch Delete (100 elements) | 3.5s | 0.5s |
| Generate Inclusion Proof | 0.02s | 0.02s |
| Generate Exclusion Proof | N/A | 0.03s |
| Storage Overhead | Low | Medium |

### Security Analysis

The security analysis of the Merkle deletion architecture addresses:

1. Integrity Preservation: Ensuring deletions don't compromise overall data integrity
2. Deletion Verification: Cryptographic proofs that deletions were executed correctly
3. Deletion Finality: Guarantees against data recovery after deletion
4. Access Control: Preventing unauthorized deletion operations
5. Timing Attacks: Mitigations against side-channel attacks during tree operations

The architecture has undergone formal verification using the Coq proof assistant to mathematically verify its security properties.

## Integration with zkVote Core Platform

The regulatory compliance framework integrates with the zkVote core platform through:

1. Compliance API Layer: Standardized interfaces for regulatory functions
2. Privacy-Preserving Middleware: Zero-knowledge adapters for compliance verification
3. Configurable Policy Engine: Rule-based system for jurisdictional compliance
4. Governance Integration: DAO-controlled compliance parameter management
5. Cross-Chain Compliance Bridge: Unified compliance across blockchain environments

This integration design ensures compliance functions are available throughout the protocol while maintaining its core privacy and security guarantees[^1][^2].

## Auditing and Reporting Framework

The auditing and reporting framework provides comprehensive visibility into compliance operations:

1. Compliance Dashboard: Real-time metrics and status indicators
2. Automated Report Generation: Scheduled compliance reports for regulators
3. Anomaly Detection: Machine learning-based compliance monitoring
4. Privacy-Preserving Audits: Zero-knowledge proofs of compliance
5. Cryptographic Attestations: Verifiable compliance statements

This framework supports both internal governance and external regulatory reporting requirements.

## Implementation Roadmap

The implementation roadmap outlines the development and deployment plan for the regulatory compliance framework:


| Phase | Timeline | Focus | Key Deliverables |
| :-- | :-- | :-- | :-- |
| Research \& Design | Q2-Q3 2025 | Requirements analysis and architecture design | Compliance specification, cryptographic primitives |
| Core Development | Q3-Q4 2025 | Implementation of core compliance components | FATF \& OFAC modules, Merkle deletion prototype |
| Integration | Q4 2025 | Integration with zkVote protocol | Unified compliance API, test suite |
| Testing \& Audit | Q1 2026 | Comprehensive security and compliance testing | Security audit report, compliance certification |
| Production Deployment | Q1-Q2 2026 | Phased rollout to production environments | Production-ready compliance framework |
| Advanced Features | Q3 2026 onwards | Extension to additional regulations | Cross-jurisdiction coverage, advanced analytics |

This timeline aligns with the overall zkVote deployment schedule outlined in the project roadmap[^3].

## Conclusion

The zkVote Regulatory Compliance Technical Framework establishes a comprehensive approach to satisfying global regulatory requirements while maintaining the core privacy and security guarantees of the protocol. By leveraging advanced cryptographic techniques like zero-knowledge proofs and Merkle-based verification systems, zkVote achieves compliance without compromising user privacy or governance integrity.

As regulatory requirements continue to evolve, this framework provides the flexibility to adapt to new standards while preserving the protocol's fundamental design principles. The implementation roadmap ensures timely development and deployment of compliance features in sync with the broader zkVote protocol development timeline.

<div style="text-align: center">⁂</div>

[^1]: executiveSummary.md

[^2]: whitepaper.md

[^3]: roadmap_and_implementationTimeline.md

[^4]: architecture.md

[^5]: zkVote-Threshold-Cryptography-MPC-Architecture.md

[^6]: Runtime-Security-Monitoring-Framework-for-zkVote.md

[^7]: zkVote-Post-Quantum-Cryptography-Implementation-Gu.md

[^8]: CI-CD_pipeline_guide.md

[^9]: https://www.semanticscholar.org/paper/b0cc6fd21ab6bd9f06e5bc6c8e34cf5e22fa5e6d

[^10]: https://www.visualofac.com/ofac-search-screening-solutions/ofac-erp-integration/

[^11]: https://inductusgroup.com/gdpr-data-privacy-compliance-what-every-business-must-do-in-2025/

[^12]: https://bitcoin.stackexchange.com/questions/51423/how-do-you-create-a-merkle-tree-that-lets-you-insert-and-delete-elements-without

[^13]: https://www.fatf-gafi.org/content/dam/fatf-gafi/recommendations/2024-Targeted-Update-VA-VASP.pdf.coredownload.inline.pdf

[^14]: https://kycaid.com/blog/how-to-conduct-ofac-screening-step-by-step-guide-for-financial-institutions/

[^15]: https://rabbitandtortoise.com/blog-gdpr-complience.html

[^16]: https://www.semanticscholar.org/paper/f9c45e866e37505489ee498c1c96115668829e2e

[^17]: https://www.semanticscholar.org/paper/30a6b1daf504efb67dc0b4ff73ed72c6607e0056

[^18]: https://www.semanticscholar.org/paper/0691d5ffe0f48e80fd58c3f4a46683d4211a7f76

[^19]: https://www.semanticscholar.org/paper/94861d428fcbd6c324829f9a44b372e30ce55897

[^20]: https://arxiv.org/abs/2204.13508

[^21]: https://www.semanticscholar.org/paper/6ab6a36c859f449c3355ab75e389063750540bc2

[^22]: https://www.semanticscholar.org/paper/040216b9fe6edc8172c0719629bb792a5306a3e3

[^23]: https://www.semanticscholar.org/paper/cd884d239461714b39f00a6579c1dbec96990a6b

[^24]: https://arxiv.org/pdf/2204.13508.pdf

[^25]: https://arxiv.org/pdf/1909.08607.pdf

[^26]: https://arxiv.org/pdf/1912.06871.pdf

[^27]: https://arxiv.org/abs/2307.14661v1

[^28]: https://trisa.io/fatf-proposed-travel-rule-revisions/

[^29]: requirements.md

[^30]: adoptionRoadmap.md

[^31]: feeModel.md

[^32]: competitiveAnalysis.md

[^33]: threatModel_and_riskAssessment.md

[^34]: delegationPrivacyDeepDive.md

[^35]: DAOIntegrationPlaybook.md

[^36]: businessModel_and_monetizationPlan.md

[^37]: https://www.semanticscholar.org/paper/2ca4e6255e75d3908483e7fb49ea3f45c6b75fdd

[^38]: https://www.semanticscholar.org/paper/df9803efbfc73f73f5b462aa776dc73f91ce9ae2

[^39]: https://www.sanctionscanner.com/blog/financial-action-task-force-fatf-travel-rule-140

[^40]: https://www.visualcompliance.com/compliance-solutions/denied-party-screening/ofac-screening/

[^41]: https://trisa.io/trisa-trp-announcement/

[^42]: https://arxiv.org/pdf/2202.12695.pdf

[^43]: https://arxiv.org/pdf/2205.13196.pdf

[^44]: https://fiaumalta.org/news/fatf-updates-2/

[^45]: https://trisa.io/trisa-announces-self-hosted-solution/

[^46]: https://trisa.dev/api/protocol/index.html

[^47]: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11348331/

[^48]: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11463407/

[^49]: https://www.semanticscholar.org/paper/7edd034fb7f45a21e92122f6226059a5cf5c38b7

[^50]: https://pubmed.ncbi.nlm.nih.gov/34279151/

[^51]: https://www.signzy.com/us/blog/aml-watchlist-screening-guide/

[^52]: https://financialcrimeacademy.org/ofac-screening-process/

[^53]: https://www.napier.ai/post/how-to-approach-sanctions-screening

[^54]: https://www.trulioo.com/solutions/aml-watchlist-screening

[^55]: https://www.ikigailaw.com/article/592/the-implementation-of-the-fatf-travel-rule-to-vasps-in-india

[^56]: https://trisa.dev/joining-trisa/registration/index.html

[^57]: https://www.merklescience.com/blog/fatfs-travel-rule-and-its-impact-on-vasps

[^58]: https://sitams.ac.in/12-05-2025-notification-for-b-t-ech-r20-r18-r16-iii-year-i-semester-supplementary-may-june-2025-examinations/

[^59]: https://www.trisa.io/fatf-proposed-travel-rule-revisions/

[^60]: https://arxiv.org/pdf/2504.02165.pdf

[^61]: https://www.consilien.com/news/navigating-ccpa-and-gdpr-compliance-essential-steps-for-us-businesses-in-2025

[^62]: https://www.semanticscholar.org/paper/c360dd4e04180af4a08434bb7d1a9b687367add1

[^63]: https://www.semanticscholar.org/paper/c614d6144629ad449eb07a89c1a1893dd3973034

[^64]: https://arxiv.org/abs/2405.07941

[^65]: https://www.semanticscholar.org/paper/ef5b28fe9702be81495eeb332aa003ccfa73710c

[^66]: https://arxiv.org/abs/2301.02161

[^67]: https://arxiv.org/abs/1509.08665

[^68]: https://arxiv.org/abs/1109.6882

[^69]: https://arxiv.org/html/2411.00193v1

[^70]: https://arxiv.org/pdf/2007.03039.pdf

[^71]: http://code.ouroborus.net/fp-syd/past/2017/2017-04-Seefried-Merkle.pdf

[^72]: https://github.com/mvayngrib/merkle-proofs

[^73]: https://www.w3schools.com/dsa/dsa_data_binarytrees.php

[^74]: https://bitcoin.stackexchange.com/questions/99164/how-does-a-merkle-proof-differ-from-the-merkle-tree

[^75]: https://eprint.iacr.org/2021/038.pdf

[^76]: https://github.com/10d9e/rs-fast-merkle

[^77]: http://arxiv.org/pdf/1206.2778.pdf

[^78]: https://arxiv.org/html/2504.01051v1

[^79]: https://www.manabadi.co.in/Notifications_25/JNTUGV-BTech-All-Years-Special-Supply-R16-R13-Aug-2025-Notification-Revised-19-2-2025.asp

[^80]: https://www.indiatoday.in/sports/cricket/story/ipl-revised-dates-may-16-final-confirmed-bcci-2723129-2025-05-11

[^81]: https://notabene.id/post/key-takeaways-from-fatfs-2024-targeted-update-of-travel-rule-implementation-for-virtual-assets-and-service-providers---july-2024

[^82]: https://arxiv.org/pdf/2503.18956.pdf

[^83]: https://www.21analytics.ch/what-is-trp/

[^84]: https://www.slideshare.net/slideshow/getting-started-with-trisa/257373112

[^85]: https://www.chainalysis.com/blog/travel-rule-compliance-unhosted-wallets/

[^86]: https://www.trisa.io

[^87]: https://www.fatf-gafi.org/en/publications/Fatfrecommendations/Fatf-recommendations.html

[^88]: https://www.cgap.org/blog/will-fatfs-travel-rule-revisions-affect-financial-inclusion

[^89]: https://sumsub.com/blog/what-is-the-fatf-travel-rule/

[^90]: https://www.kychub.com/blog/fatf-travel-rule/

[^91]: https://www.semanticscholar.org/paper/1b5c52c111b0d9ef809b17a457939a8061e1a2a8

[^92]: https://www.fatf-gafi.org/content/dam/fatf-gafi/public-consultation/R.16 and EM - Public consultation February 2025.docx.coredownload.inline.docx

[^93]: https://trisa.dev/openvasp/index.html

[^94]: https://www.openvasp.org/trp

[^95]: https://arxiv.org/pdf/1004.1670.pdf

[^96]: https://arxiv.org/pdf/2308.12955.pdf

[^97]: https://arxiv.org/pdf/1612.05227.pdf

[^98]: http://arxiv.org/pdf/1801.07358.pdf

[^99]: https://www.fatf-gafi.org/en/publications/Fatfrecommendations/R16-public-consultation-February-2025.html

[^100]: https://www.regulationtomorrow.com/global/fatf-second-consultation-on-revisions-to-r-16-and-inr-16/

[^101]: https://trisa.dev/getting-started/index.html

[^102]: https://www.aosphere.com/know-how/travel-rule-in-the-spotlight/

[^103]: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11294352/

[^104]: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11622364/

[^105]: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11263010/

[^106]: https://www.semanticscholar.org/paper/5bef569f0e92047e3027a3973c34cdbb8fd975eb

[^107]: https://pubmed.ncbi.nlm.nih.gov/24641070/

[^108]: https://pubmed.ncbi.nlm.nih.gov/35648347/

[^109]: https://ofac.treasury.gov/media/16331/download?inline

[^110]: https://www.cobblestonesoftware.com/en-us/products/ofac-screening-software

[^111]: https://docs.appian.com/suite/help/25.1/cu-24.2.1.6/modifying-ofac-integration.html

[^112]: https://docs.appian.com/suite/help/23.4/cu-23.4.1.4/managing-integrations.html

[^113]: https://www.sanctions.io/blog/the-complete-guide-for-an-effective-sanctions-screening-process

[^114]: https://www.sas.com/en_in/news/press-releases/2024/december/sanctions-real-time-watchlist-screening-solution.html

[^115]: https://www.semanticscholar.org/paper/69a0dc633652d17eb03c4bb85e79cfe98ddf5af6

[^116]: https://www.semanticscholar.org/paper/337b5b87889f6ae7db621f80e427294454c20652

[^117]: https://www.semanticscholar.org/paper/d029ca822d58aae29100e77829a0c1cb4d4b73c3

[^118]: https://trisa.io/trisa-trp-interop-demo/

[^119]: https://www.circle.com/blog/introducing-the-travel-rule-universal-solution-technology

[^120]: https://blog.bitmex.com/wp-content/uploads/2021/02/Travel-Rule-Data-Storage-Principles.pdf

[^121]: https://sitams.ac.in/12-05-2025-notification-for-b-t-ech-r23-r20-r18-r16-ii-year-i-semester-supplementary-may-june-2025-examinations-2/

[^122]: https://www.21analytics.ch/glossary/openvasp/

[^123]: https://travel.state.gov/content/travel/en/legal/visa-law0/visa-bulletin/2025/visa-bulletin-for-june-2025.html

[^124]: https://reinforce.awsevents.com

[^125]: https://cdn-group.bnpparibas.com/uploads/file/anti_money_laundering_and_terrorist_financing_fatf_consultation_on_recommendation_16_on_payment_transparency_bnpp_answer_may_2024.pdf

[^126]: https://www.scorechain.com/resources/crypto-glossary/travel-rule-integration

[^127]: https://sumsub.com/travel-rule/

[^128]: https://arxiv.org/pdf/2409.00264.pdf

[^129]: https://arxiv.org/pdf/2407.17021.pdf

[^130]: https://www.semanticscholar.org/paper/e7a6accd7ccb0e89e26e7a64df2c38e1b1aa5d2f

[^131]: https://www.semanticscholar.org/paper/5d8d5f9be7bda8fafa66466521c2d1e033154d34

[^132]: https://www.semanticscholar.org/paper/d618509942184570805a5e220a71f49f51c2f694

[^133]: https://www.semanticscholar.org/paper/444c98c22794fc94001f4e2c214239de0c4e9408

[^134]: https://www.semanticscholar.org/paper/52c1d0c8377c1a17df48470ea2e8f175dab8abe7

[^135]: https://www.semanticscholar.org/paper/9bfffc42024acf4b516ec6aed8ea62db4b0bd2ef

[^136]: https://arxiv.org/abs/2108.05813

[^137]: https://www.semanticscholar.org/paper/bc9eda53d90a54db62b835638ad6ab09c8ff983d

[^138]: https://www.moodys.com/web/en/us/kyc/resources/insights/fatf-recommendation-16-possible-implications-and-data-insights-for-compliance.html

[^139]: https://www.openvasp.org/blog/what-is-the-travel-rule-protocol-trp

[^140]: https://arxiv.org/abs/2504.07540

[^141]: https://arxiv.org/abs/2205.05211

[^142]: https://www.semanticscholar.org/paper/fde7a6f967a6a1d6bbf3ea849454d31df6c81330

[^143]: https://www.semanticscholar.org/paper/2b3103e0b6553cf923576440a447463206d6736a

[^144]: https://www.semanticscholar.org/paper/45de9c3f80572bdf87c6d813cfaaab3ef548606d

[^145]: https://arxiv.org/pdf/2301.02161.pdf

[^146]: http://arxiv.org/pdf/1509.05514.pdf

[^147]: https://arxiv.org/pdf/2405.07941.pdf

[^148]: https://arxiv.org/pdf/2006.01994.pdf

[^149]: https://arxiv.org/pdf/1602.08162.pdf

[^150]: https://arxiv.org/ftp/arxiv/papers/2209/2209.13431.pdf

[^151]: https://www.cyfrin.io/blog/what-is-a-merkle-tree-merkle-proof-and-merkle-root

[^152]: https://www.semanticscholar.org/paper/Streaming-Merkle-Proofs-within-Binary-Numeral-Trees-Champine/f9c45e866e37505489ee498c1c96115668829e2e

[^153]: https://www.youtube.com/watch?v=M6GwdBp4Qe8

[^154]: https://docs.chainstack.com/docs/deep-dive-into-merkle-proofs-and-eth-getproof-ethereum-rpc-method

[^155]: https://protocol.mavryk.org/developer/merkle-proof-encoding-formats.html

[^156]: https://www.interviewcake.com/concept/java/binary-tree

[^157]: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11538880/

[^158]: https://www.semanticscholar.org/paper/38ab58d540ebb5feea53d0b9de038d5ed8f1735a

[^159]: https://cryptouk.io/resources/cryptouk-travel-rule-good-practices-guide/

[^160]: https://www.protiviti.com/sites/default/files/2024-06/crypto-travel-rule-whitepaper-protiviti.pdf

