# Node Hooked Changelog
This is a simple BASH based changelog generator for NodeJS projects that are versioned using `npm version`. It uses a git post-commit hook to trigger, and looks for the standard commit message format produced by `npm version`, e.g. `v0.0.1`. When it detects a commit that contains a message in this format it runs the generator script and produces a Markdown formatted changelog by default.

You can customize the changelog format by specifying your own simple template files.

## Installation
`npm install --save node-hooked-changelog`

## Usage
The changelog generator should work out of the box, but for optimal changelogs you might want to customize a few settings.

You can specify settings for your changelog in your `package.json` file under the `changelog` key. Here's an example snippet showing all the available settings:

```json
{
	...
	"changelog": {
		"title": "My Cool Project",
		"commit-url": "https://github.com/jbloggs/my-cool-project/commit/${commitId}",
		"issue-url": "https://github.com/jbloggs/my-cool-project/issues/${issueId}",
		"template": {
			"header": "./changelog-templates/header.template",
			"footer": "./changelog-templates/footer.template",
			"commit": "./changelog-templates/commit.template",
			"issue": "./changelog-templates/issue.template",
			"version": "./changelog-templates/version.template"
		}
	},
	...
}

```

If not specified sensible defaults will be used for all options. Further explanation of options is shown below:

## Configuration options
### title
The title to include in the header template, this is used to give a nicely formatted name for your project in the header of your changelog. If not specified it will default to the `name` property from your `package.json`.

### commit-url
The url to use to link to specific commits, generally this will be a github project url. Available parameters are `commitId`.

### issue-url
The url to use to link to issues, issues are detected in your log messages using the `#12345` syntax. If not specified, this will fall back to the `bugs` url specified in your `package.json` or empty if neither string is specified.

### templates
This object specifies a variety of different templates use to create your changelog, see below for more details.

## Templates
Templates are simply text files with standard Bash variable expansions. The options available to templates vary depending on the template, see below for more details. The `node-hooked-changelog` module comes with basic templates to create a simple Markdown formatted changelog. If you want a different formatting you can override any of the templates by specifying them in your `package.json`.

### header
This is output at the start of your changelog.

Available properties are:
- `moduleName` - the module name specified in `package.json`
- `title` - specified in your `package.json` under `changelog` property (see above).

Defaults to:
```
# ${title} Changelog
```

### footer
This is output at the end of your changelog.

Available properties are:
- `moduleName` - the module name specified in `package.json`
- `title` - specified in your `package.json` under `changelog` property (see above).

Defaults to:
```

*...here be dragons*


Generated with [node-hooked-changelog](http://github.com/SupplyFrame/node-hooked-changelog)
```

### commit
This template is used repeatedly for each commit message that is output into your changelog.

Available properties are: 
- `commitUrl` - the url of this commit (see `commit-url` for more details)
- `version` - the version number that includes this commit
- `commitId` - the commit id for this commit
- `commitMessage` - the commit message included with this commit

Defaults to:
```
- ${commitMessage} - [view commit](${commitUrl})
```

### issue
This template is used wherever an issue number is detected in your commit messages, issues are detected by a number prefixed with a #, e.g. #1234.

Available properties are: 
- `issueUrl` - the url to this issue (see `issue-url` for more details)
- `issueId` - the id of this issue
- `commitId` - the commit id for the commit this issue reference was found in

Defaults to:
```
[#${issueId}](${issueUrl})
```

### version
This template is used whenever a new version tag is encountered in your git log. This serves as a divider for each new version of your application in your changelog.

Available properties are: 
- `commitUrl` - the url of the commit that changed the version (see `commit-url` for more details)
- `version` - the version number specified in this commit
- `commitId` - the commit id for this commit

Defaults to:
```
##[v${version}](${commitUrl})
```