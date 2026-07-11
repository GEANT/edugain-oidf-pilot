
# OpenID Federation Test Cases

This document defines test cases for OpenID Federation in eduGAIN. This includes interoprability tests for Trust Anchors, Relying Party's, and OpenID Providers. 

---

## Test Preconditions and Dependencies

| Ref | Area | Preconditions / Dependencies |
|------|------|-------------------------------| 
| **P-01** | Federation Entities | Valid OP and RP federation entity configurations are available, each with correct metadata and signing keys. |
| **P-02** | Trust Anchor Endpoints | The TA exposes `/fetch`, `/list`, and `/resolve` endpoints per OpenID Federation specification. |
| **P-03** | Network & Authentication | All components (TA, OP, RP) can communicate over HTTPS. |
| **P-04** | Trust Marks | Trust mark issuers and validation endpoints are available and reachable. |
| **P-05** | Logging & Monitoring | Logging enabled on TA, OP, and RP components to record enrolment, key, and trust evaluation events. |
| **P-06** | Caching | Unless the test specifically exercises the caching components, caching of entity statements and configurations should be disabled |


## Test Architectures

| Ref | Type | Topology & Description |
|------|-----------|-------------------------------|
| **TA-01** | Basic | A single Trust Anchor managing enrolment and trust for one OP and one RP. |
| **TA-02** | Hierarchical Single-Root | A root Trust Anchor delegates trust to a single intermediate authority, which manages one OP and one RP. |
| **TA-03** | Hierarchical Single-Root, Multi-Intermediate | A single Trust Anchor with two intermediate authorities; each intermediate manages its own OP and RP. |
| **TA-04** | Hierarchical Multi-Intermediate and Multi-Root | Two Trust Anchors: the first has two intermediates with an OP and RP each; the second has an OP and RP, but the OP also connects to one intermediate from the first Trust Anchor, forming a cross administrative federation link. |



### TA-01: Basic Topology

```
      [ Trust Anchor (Root) A ]
                  |
        ---------------------
        |                   |
     [ OP ]               [ RP ]
```

### TA-02: Hierarchical Single-Root Topology

```
          [ Trust Anchor (Root) A ]
                    |                   
            [ Intermediate A ]     
                    |                     
            -----------------           
            |               |           
        [ OP ]           [ RP ]        
```
### TA-03: Hierarchical Single-Root, Multi-Intermediate Topology (eduGAIN)

```
                [ Trust Anchor (Root) A ]
                         |
        -----------------------------------------
        |                                       |
  [ Intermediate A ]                    [ Intermediate B ]
        |                                       |
   ---------------                         ---------------
   |             |                         |             |
 [ OP ]        [ RP ]                   [ OP ]        [ RP ]
```

### TA-04: Hierarchical Multi-Root Topology

```
          [ Trust Anchor (Root) A ]                     
                  |            
        ------------------------- 
        |                       |  
[ Intermediate A ]      [ Intermediate B ]      [ Trust Anchor (Root) B ]
        |                       |                        |
   -------------           ------------------       ---------------- 
   |           |           |           |    |-------|             |
 [ OP ]      [ RP ]      [ OP ]      [ RP ]        [OP]          [RP]
 
```

### TA-05: Basic Topology with Trust Mark Issuer 

```
      [ Trust Anchor (Root) A ] -->[ Trust Mark Issuer A]
                  |
        ---------------------
        |                   |
     [ OP ]               [ RP ]
```


### TA-06: Hierarchical Single-Root, Multi-Intermediate Topology with Trust Mark Issuers (eduGAIN)

```
                     [ Trust Anchor (Root) A ] -->[ Trust Mark Issuer A]
                                  |
        -------------------------------------------------
        |                                               |
  [ Intermediate A ] -->[ Trust Mark Issuer B]   [ Intermediate B ]-->[ Trust Mark Issuer C]
        |                                               |
   ---------------                                 ---------------
   |             |                                 |             |
 [ OP ]        [ RP ]                            [ OP ]        [ RP ]
```

Noting: TA-01 represents national federation use cases, and TA-02 to TA-04 represent international federation use cases, such as eduGAIN. In addition, TA-05 and TA-06 introduce Trust Mark Issuers to validate trust mark scenarios.

In each test case, the architecture reference (e.g., TA-01) indicates which is the *minimum* topology to use to satisfy the given test—the same test can apply to other topologies.

## Federation Enrolment Test Cases

| Ref    | Arch | Requirement Level | Test Type                                      | Requirement Summary                              | Test Action                                              | Expected Outcome                                               |
|--------|------|--------------|-----------------------------------------------|-------------------------------------------------|----------------------------------------------------------|----------------------------------------------------------------|
| **FE-01**  | TA-01 | MUST              | Enrolment            | Trust Anchors can enroll RPs                   | Enrol RP into Trust Anchor                               | RP appears in `/list` and `/fetch` returns RP Entity Statement   |
| **FE-02**  | TA-01 | MUST              | Enrolment            | Trust Anchors can enroll OPs                   | Enrol OP into Trust Anchor                               | OP appears in `/list` and `/fetch` returns OP Entity Statement   |
| **FE-03**  | TA-02 | MUST              | Enrolment              | National federations can join international federations | Enrol TA into another TA                                 | TA appears in `/list` and `/fetch` returns TA (now intermediate) Entity Statement   |
| **FE-04**  | TA-01 | SHOULD            | Enrolment      | Policy-based enrolment by Entity ID            | Attempt OP enrolment under policy allowing by Entity ID  | OP listed in `/list` and `/fetch` returns OP Entity Statement    |
| **FE-05**  | TA-01 | SHOULD            | Enrolment      | Policy-based enrolment by Entity ID            | Attempt OP enrolment under policy disallowing by Entity ID | OP **not** listed in `/list` and `/fetch` does not return OP Entity Statement   |
| **FE-06**  | TA-01 | SHOULD            | Enrolment    | Policy-based enrolment by Trust Marks          | Attempt OP enrolment with eduGAIN Trust Mark under policy requiring it | OP listed in `/list` and `/fetch` returns OP Entity Statement    |
| **FE-07**  | TA-01 | SHOULD            | Enrolment    | Policy-based enrolment by Trust Marks          | Attempt OP enrolment without eduGAIN Trust Mark under policy requiring it | OP **not** listed in `/list` and `/fetch` does **not** return OP Entity Statement   |
| **FE-08**  | TA-01 | SHOULD            | Enrolment      | Policy-based enrolment by Entity ID            | Attempt RP enrolment under policy allowing by Entity ID  | RP listed in `/list` and `/fetch` returns RP Entity Statement    |
| **FE-09**  | TA-01 | SHOULD            | Enrolment      | Policy-based enrolment by Entity ID            | Attempt RP enrolment under policy disallowing by Entity ID | RP not listed in `/list` and `/fetch` does **not** return RP Entity Statement   |
| **FE-10**  | TA-01 | MUST              | Update                  | Support updates to Entities                    | Update existing entity registration                      | Entity updated; only owner can update; non-owners rejected    |
| **FE-11**  | TA-01 | MUST              | Enrolment       | Override display attributes                    | Enrol entity with TA-authorised display attributes       | Entity Statement includes required attributes in `metadata`   |
| **FE-12**  | TA-01 | MUST              | Unenrolment                | Support unenrolment of RP entities                | Unenrol RP from Trust Anchor                             | RP removed from `/list`; `/fetch` does **not** return RP Entity Statement |
| **FE-13**  | TA-01 | MUST              | Unenrolment                 | Support unenrolment of OP entities                | Unenrol OP from Trust Anchor                             | OP removed from `/list`; `/fetch` does **not** return RP Entity Statement |
| **FE-14**  | TA-02 | MUST              | Unenrolment                  | National federations can leave international federations | Unenrol TA from another TA                               | TA (Intermediate) removed from `/list`; `/fetch` does **not** return Entity Statement |
| **FE-16**  | TA-01 | MAY               | Enrolment       | Validate signing keys during enrolment         | Attempt OP enrolment with expired signing key as determined by the `federation_historical_keys` endpoint    | Enrolment rejected; error indicates signing key is expired   |


---

## Key Management Test Cases

| Ref    | Arch | Requirement Level | Test Type                                      | Requirement Summary                              | Test Action                                              | Expected Outcome                                               |
|--------|------|--------------|-----------------------------------------------|-------------------------------------------------|----------------------------------------------------------|----------------------------------------------------------------|
| **KM-01**  | TA-01| MUST              | Key Rollover            | Add new federation signing key without breaking trust | Add new signing key to TA’s JWK set, keep signing with the existing key | Entities recognize the new key as trusted                     |
| **KM-02**  | TA-01| MUST              | Key Rollover           | Leaf entities trust documents signed with new keys | Validate trust of documents signed with new key          | Entities verify documents signed with new key                 |
| **KM-03**  | TA-01| MUST              | Key Rollover         | Remove old federation signing key safely        | Remove old signing key from TA’s JWK set                | Only current keys trusted; old keys appear in `federation_historical_keys` |
| **KM-04**  | TA-01| MUST              | Key Revocation                | Revoke TA signing key                           | Test impact of revoking TA signing key                  | Documents signed with revoked key are rejected; trust not established |
| **KM-05** | TA-01| MUST              | Key Revocation                 | Revoke OP federation signing key                | Revoke OP signing key                                   | OP federation documents no longer trusted                     |
| **KM-06**  | TA-01| MUST              | Key Revocation                 | Revoke RP federation signing key                | Revoke RP signing key                                   | RP federation documents no longer trusted                     |


//TODO updating keys at the TA and ensuring entities pick up the changes
---

## Trust Mark Test Cases


| Ref    | Arch | Requirement Level | Test Type                                      | Requirement Summary                              | Test Action                                              | Expected Outcome                                               |
|--------|-------|-------------|-----------------------------------------------|-------------------------------------------------|----------------------------------------------------------|----------------------------------------------------------------|
| **TM-01**  | TA-05 | MUST            | Trust Mark Issuance                   | Issue valid trust marks to OPs                 | Issue federation membership trust mark (e.g., eduGAIN) to OP | Trust mark is correctly formatted and signed                  |
| **TM-02**  | TA-05 | MUST            | Trust Mark Issuance                   | Issue valid trust marks to RPs                 | Issue federation membership trust mark (e.g., eduGAIN) to RP | Trust mark is correctly formatted and signed                  |
| **TM-03**  | TA-05 | MUST              | Trust Mark Usage          | OPs enforce trust mark requirements for RPs    | Verify OP requires RP to have eduGAIN trust mark         | OP rejects RP without required trust mark                     |
| **TM-04**  | TA-05 | MUST              | Trust Mark Usage         | RPs enforce trust mark requirements for OPs    | Verify RP requires OP to have eduGAIN trust mark         | RP rejects OP without required trust mark                     |
| **TM-05**  | TA-05 | MUST              | Trust Mark Revocation       | OPs do not trust revoked or expired trust marks | Revoke/expire RP trust mark and attempt trust establishment | Trust not established; TA trust mark status endpoint reflects correct status |
| **TM-06**  | TA-05 | MUST              | Trust Mark Revocation       | RPs do not trust revoked or expired trust marks | Revoke/expire OP trust mark and attempt trust establishment | Trust not established; TA trust mark status endpoint reflects correct status |
| **TM-07**  | TA-06 | TBD               | Trust Mark Delegation                        | Validate trust mark delegation scenarios       | TBD                                                     | TBD                                                            |


---

## Federation Entity Discovery & Metadata Handling Test Cases


| Ref    | Arch | Requirement Level | Test Type                                      | Requirement Summary                              | Test Action                                              | Expected Outcome                                               |
|--------|------|--------------|-----------------------------------------------|-------------------------------------------------|----------------------------------------------------------|----------------------------------------------------------------|
| **FD-01**  | TA-02 | MAY               | Trust Path Resolution               | Validate embedded trust chains in RP request    | Parse and validate embedded trust chain in Request Object | OP establishes trust if embedded chain is valid               |
| **FD-02**  | TA-02 | MUST              | Trust Path Resolution   | Reject expired statements in embedded trust chain | Validate OP rejects expired Entity Statements in embedded chain | OP rejects embedded chain but succeeds via Federation Entity Discovery   |
| **FD-03**  | TA-02 | MUST              | Trust Path Resolution   | Reject expired statements during entity discovery | Validate OP rejects expired Entity Statements during discovery | OP fails to establish trust due to expired statement          |
| **FD-04**  | TA-04 | SHOULD            | Trust Path Resolution                         | Select shortest valid trust path                | Validate OP selects shortest valid trust path among multiple | OP selects shortest, common, valid path and establishes trust          |
| **FD-05**  | TA-02 | MUST              | Metadata Constraints                        | Enforce allowed entity types                    | Validate OP/RP enforce entity type constraints that only allow `openid_relying_party` and `openid_provider` entities   |  Trust chain resolution fails when entity changes to `federation_entity`           |
| **FD-06**  | TA-02 | MUST              | Metadata Constraints                    | Enforce maximum trust path length               | Validate OP/RP enforce `max_path_length` policy            | Trust chain resolution fails if path length exceeded          |
| **FD-07**  | TA-01 | SHOULD            | Metadata Policy                           | Inject policy-driven metadata                   | Validate TA adds contact info into OP/RP metadata        | Resolved metadata contains added contact information          |
| **FD-08**  | TA-01 | SHOULD            | Metadata Policy                        | Enforce cryptographic algorithm constraints     | Validate TA enforced allowed `id_token` signing algorithm (`RS256`)   | Trust chain validation resolution fails if OP/RP publishes unsupported signing algorithm(s)      |
| **FD-09**  | TA-01 | SHOULD            | Metadata Augmentation                 | Override self-asserted metadata                 | Validate TA overrides metadata fields like `display_name`  | Clients use TA-defined metadata values                        |
| **FD-10**  | TA-01 | SHOULD            | Metadata Augmentation                      | TA provides metadata during trust resolution     | Validate TA-provided metadata applied during resolution  | TA-provided metadata visible in resolved configuration        |
| **FD-11**  | TA-03 | MAY               | Trust Path Resolution                           | OPs and RPs support multiple trust resolvers                | Validate OP switches between resolvers for redundancy    | OP establishes trust using any available resolver             |


//TODO multiple resolvers may provide different filtering / policies - how to test that?


---

## Client Registration Test Cases

| Ref    | Arch | Requirement Level | Test Type                                      | Requirement Summary                              | Test Action                                              | Expected Outcome                                               |
|--------|------|--------------|-----------------------------------------------|-------------------------------------------------|----------------------------------------------------------|----------------------------------------------------------------|
| **CR-01**  | TA-01 | MAY               | Explicit Registration             | Support explicit registration                   | RP registers explicitly with OP using `client_secret_basic` | RP receives valid credentials (`client_id`, `client_secret`) and can authenticate |
| **CR-02**  | TA-01 | MUST              | Explicit Registration           | Provide error handling for failed explicit registration | Attempt explicit registration when trust cannot be established | OP returns compliant error response                            |
| **CR-03**  | TA-01 | MUST              | Automatic Registration | Support automatic registration with signed JWT  | RP registers automatically using signed Request Object JWT | RP receives valid authentication response; trust established   |
| **CR-04**  | TA-01 | MUST              | Automatic Registration | Support automatic registration with signed & encrypted JWT | RP registers automatically using signed and encrypted Request Object JWT | RP receives valid authentication response; trust established   |
| **CR-05**  | TA-01 | MUST              | Automatic Registration          | Provide error handling for failed automatic registration | Attempt automatic registration when trust cannot be established | OP terminates flow with error; no redirect to `redirect_uri`   |
| **CR-06**  | TA-02 | MUST              | Automatic Registration | Support automatic registration with hierarchical trust chain | RP registers automatically using signed JWT with hierarchical trust chain | RP receives valid authentication response; trust established through chain |
| **CR-07**  | TA-02 | MUST              | Explicit Registration    | Support explicit registration with hierarchical trust chain | RP registers explicitly using signed JWT with hierarchical trust chain | RP receives valid authentication response; trust established through chain |

---

## Client Authentication Test Cases

| Ref    | Arch | Requirement Level | Test Name                                      | Requirement Summary                              | Test Action                                              | Expected Outcome                                               |
|--------|------|--------------|-----------------------------------------------|-------------------------------------------------|----------------------------------------------------------|----------------------------------------------------------------|
| **CA-01**  | TA-01 | MAY              | Endpoint Authentication           | Authenticate clients for `/resolve` endpoint, ensure that access to the resource-intensive and bandwidth-heavy resolution functionality is restricted to authorized clients    | Attempt to access `/resolve` without authentication      | Only authenticated clients can retrieve resolved Entity Statements |
| **CA-02**  | TA-01 | MAY              | Endpoint Authentication             | Authenticate clients for `/fetch` endpoint, ensure that access to the resource-intensive fetch functionality is restricted to authorized clients      | Attempt to access `/fetch` without authentication        | Only authenticated clients can access signed Entity Statements |
| **CA-03**  | TA-01 | MAY              | Endpoint Authentication              | Authenticate clients for `/list` endpoint, prevent enumeration of entities to unauthorized clients       | Attempt to access `/list` without authentication         | Only authenticated clients can retrieve entity lists           |


---



