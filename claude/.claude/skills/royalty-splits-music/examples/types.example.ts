// RoyaltySplit shape — MASTER vs PUBLISHING bucket pattern, XOR scope.
// Extracted from royalty-splits-music/SKILL.md.
//
// Invariants (enforced by validation, not the type):
//   - sum(percentage) per (scope, rightsType, territory) === 100
//   - exactly one of recordingId | releaseId is set per row
//   - re-validate after delete (deletes can leave a bucket at 75%)

type RightsType = 'MASTER' | 'PUBLISHING'

type RoyaltySplit = {
  personId: string         // payee
  rightsType: RightsType   // bucket
  percentage: number       // 0-100
  recordingId?: string     // XOR with releaseId
  releaseId?: string       // XOR with recordingId
  territory?: string       // ISO 3166 or 'WORLD'
}
