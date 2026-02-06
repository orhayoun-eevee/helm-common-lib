# Validation Rules Inventory (Pre-Refactor)

Inventory of all validation rules from the complex validation system, mapped to new pattern.

## Global (_global.tpl)
| Rule | New Pattern |
|------|-------------|
| global.name required/empty | `required "global.name is required" .Values.global.name` |
| global.name DNS-1123 | `fail` + libChart.validation.dns1123 |
| global.name length <= 63 | `fail` with printf |
| global.namespace required/empty | `required "global.namespace is required" .Values.global.namespace` |

## Deployment (_deployment-validations.tpl)
| Rule | New Pattern |
|------|-------------|
| deployment.containers required | `fail` when not .Values.deployment.containers |
| deployment.containers not empty | `fail` when len 0 |
| container.image required (enabled) | `required` per container |
| container.image.repository required/empty | `required` |
| container.image.tag required/empty | `required` |
| deployment.replicas >= 0 | `fail` when lt 0 |

## HTTPRoute (_httproute-validations.tpl)
| Rule | New Pattern |
|------|-------------|
| host required/empty | `required` |
| port required | `required` |
| gateway required | `required` gateway.name, gateway.namespace |
| gateway.name required/empty | `required` |
| gateway.namespace required/empty | `required` |
| port range 1-65535 | `fail` + libChart.validation.port |

## Service (_service-validations.tpl)
| Rule | New Pattern |
|------|-------------|
| ports required when service enabled | `fail` when not ports or len 0 |
| ports not empty | `fail` |

## DestinationRule (_destinationrule-validations.tpl)
| Rule | New Pattern |
|------|-------------|
| host required/empty | `required` |

## PVC (_pvc-validations.tpl)
| Rule | New Pattern |
|------|-------------|
| claim.size required/empty | `required` |
| claim.size format | `fail` + libChart.validation.size |
| claim.storageClass required/empty | `required` |

## ServiceMonitor (_servicemonitor-validations.tpl)
| Rule | New Pattern |
|------|-------------|
| port required | `required` |
| port range 1-65535 | `fail` + libChart.validation.port |
| interval format (optional) | `fail` + libChart.validation.duration |
| scrapeTimeout format (optional) | `fail` + libChart.validation.duration |

## SealedSecret (_sealedsecret-validations.tpl)
| Rule | New Pattern |
|------|-------------|
| data required | `fail` |
| data not empty | `fail` when len 0 |

## PDB (_pdb-validations.tpl)
| Rule | New Pattern |
|------|-------------|
| minAvailable and maxUnavailable mutually exclusive | `fail` |
| one of minAvailable or maxUnavailable required | `fail` |

## Helpers (kept in _validations.tpl)
- libChart.validation.dns1123 (_naming.tpl)
- libChart.validation.port (_networking.tpl)
- libChart.validation.size (_storage.tpl)
- libChart.validation.duration (_time.tpl)
