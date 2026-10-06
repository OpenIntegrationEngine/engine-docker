// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2026 BrightCodeCompany OÜ

import fs from 'fs'

const severityToColor = (severity: string) => {
    switch (severity.toLowerCase()) {
        case 'critical':
            return '🔴'
        case 'high':
            return '🟠'
        case 'medium':
            return '🟡'
        case 'low':
            return '⚪'
    }
}

const getReportJson = ()  => {
    try {
        const report = fs.readFileSync('sarif.json', 'utf8')
        return JSON.parse(report)
    } catch (err) {
        console.error(err)
        process.exit(1)
    }
}

const writeReportToFile = (markdown: string)  => {
    try {
        fs.writeFileSync('report.md', markdown)
    } catch (err) {
        console.error(err)
        process.exit(1)
    }
}

const renderCve = (cve: object) => {
    const pUrl = cve.properties.purls[0]
    const packageName = pUrl.replace("pkg:", "").split("@")[0]
    const installedVersion = pUrl.split("@")[1]
    const severity = cve.properties.cvssV3_severity
    const sevScore = cve.properties.cvssV3
    const fixedVersion = cve.properties.fixed_version
    return `| [${cve.id}](${cve.helpUri}) | ${severityToColor(severity)} | ${sevScore} | \`${packageName}\` | \`${installedVersion}\`   | \`${fixedVersion}\`  |`
}

const main = (imageTag: string, imageDigest: string, startTime: Instant) => {
    const report = getReportJson().runs[0]

    const sortedCve = report.tool.driver.rules.sort((a: object, b: object) => {
        return b.properties.cvssV3 - a.properties.cvssV3
    })

    let cveStrings: string[] = []
    let cvssMap: { [severity: string]: number } = {}
    for (const cve of sortedCve) {
        const cveString = renderCve(cve)

        cvssMap[cve.properties.cvssV3_severity] = (cvssMap[cve.properties.cvssV3_severity] || 0) + 1
        cveStrings.push(cveString)
    }
    const driver = report.tool.driver

    const markdown = `
## Scan

|             |                                                                 |
|-------------|-----------------------------------------------------------------|
| **Target**  | \`${imageTag}\`                                 |
| **Digest**  | \`${imageDigest}\`                                 |
| **Scanner** | \`${driver.fullName} ${driver.version}\`                |
| **Timestamp** | \`${startTime.toString()}\` |
| **Filter**  | \`severity ≥ High; base-image vulns excluded\` |

**Totals:** 🔴 Critical \`${cvssMap['CRITICAL'] || 0}\` · 🟠 High \`${cvssMap['HIGH'] || 0}\` · 🟡 Medium \`${cvssMap['MEDIUM'] || 0}\` · ⚪ Low \`${cvssMap['LOW'] || 0}\`

## Findings

| CVE  | Sev | CVSS | Package | Installed | Fixed in |
|------|-----|------|---------|-----------|----------|
${cveStrings.join('\n')}
`
    writeReportToFile(markdown)
}

const args = process.argv.slice(2)
console.log(args)

const imageTag = `openintegrationengine/engine:${args[0]}`
const imageDigest = args[1]
const startInstant = Temporal.Instant.from(args[2])

main(imageTag, imageDigest, startInstant)
