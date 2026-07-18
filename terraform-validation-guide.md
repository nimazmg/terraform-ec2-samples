# Terraform Validation: A Beginner's Guide

This guide explains the `validation` blocks used in this project's
`variables.tf` files.

## 1. What Validation Means

Validation means checking that an input follows a rule **before Terraform tries
to use it to create infrastructure**.

For example, an EC2 instance count should be a positive whole number. Values
such as `0`, `-2`, or `1.5` do not make sense for this project. A validation
block rejects those values early and displays a helpful message.

Think of validation as an entrance check:

```text
User supplies a value
        |
        v
Does it pass the validation rule?
        |
   +----+----+
   |         |
  yes        no
   |         |
continue   stop and show the error message
```

Validation does not create anything in AWS. It only checks configuration data.

## 2. Basic Syntax

A validation block belongs inside a `variable` block:

```hcl
variable "instance_count" {
  type    = number
  default = 2

  validation {
    condition     = var.instance_count >= 1
    error_message = "instance_count must be at least 1."
  }
}
```

It has two important parts:

- `condition` is an expression that must evaluate to `true`.
- `error_message` tells the user what is wrong when the condition is `false`.

For `instance_count = 2`, the expression `2 >= 1` is `true`, so Terraform
continues.

For `instance_count = 0`, the expression `0 >= 1` is `false`, so Terraform
stops and prints:

```text
instance_count must be at least 1.
```

## 3. Type Checking and Validation Are Different

The `type` argument performs basic type checking:

```hcl
variable "instance_count" {
  type = number
}
```

It rejects text such as `"two"` because that is not a number. However, the type
alone still accepts `-10` and `2.5` because both are numbers.

A validation block adds rules about which numbers are acceptable:

```hcl
validation {
  condition = (
    var.instance_count >= 1 &&
    var.instance_count == floor(var.instance_count)
  )
  error_message = "instance_count must be a whole number of at least 1."
}
```

This condition checks two things:

1. `var.instance_count >= 1` — the value is positive.
2. `var.instance_count == floor(var.instance_count)` — the value has no
   fractional part.

The `&&` operator means **and**, so both checks must be true.

| Value | At least 1? | Whole number? | Valid? |
|---:|---|---|---|
| `2` | Yes | Yes | Yes |
| `0` | No | Yes | No |
| `-1` | No | Yes | No |
| `1.5` | Yes | No | No |

## 4. Boolean Operators

Validation conditions often combine smaller checks.

| Operator | Meaning | Example |
|---|---|---|
| `&&` | and | both conditions must be true |
| `\|\|` | or | at least one condition must be true |
| `!` | not | reverses true and false |
| `==` | equals | `var.port == 80` |
| `!=` | does not equal | `var.port != 0` |
| `>=` | greater than or equal | `var.port >= 1` |
| `<=` | less than or equal | `var.port <= 65535` |

Parentheses help group a longer expression:

```hcl
condition = (
  var.listener_port >= 1 &&
  var.listener_port <= 65535
)
```

This accepts valid TCP/UDP port numbers from `1` through `65535`.

## 5. Multiple Validation Blocks

A variable can have several validation blocks. Terraform requires all of them
to pass.

The `network` variable in this project separately checks:

- The VPC CIDR is valid.
- The default-route CIDR is valid.
- At least two public subnets exist.
- Every subnet has a valid CIDR.
- Subnet CIDRs are unique.
- Subnets use different availability zones.

Keeping different rules in separate blocks can produce more specific error
messages.

## 6. Common Functions Used in This Project

### `length`

`length` counts characters or collection items:

```hcl
condition = length(var.project_name) <= 20
```

This ensures the project name contains no more than 20 characters.

For a list or map:

```hcl
condition = length(var.network.public_subnets) >= 2
```

This requires at least two subnet entries.

### `trimspace`

`trimspace` removes spaces from the beginning and end of text:

```hcl
condition = length(trimspace(var.aws_region)) > 0
```

An input containing only spaces becomes an empty string and is rejected.

### `contains`

`contains` checks whether a list contains a value:

```hcl
condition = contains(["x86_64", "arm64"], var.compute.ami.architecture)
```

Only `x86_64` and `arm64` are accepted.

It can also check whether a map contains a key:

```hcl
condition = contains(
  keys(var.network.public_subnets),
  var.compute.subnet_key
)
```

`keys(...)` produces a list of subnet keys. `contains(...)` then confirms that
the selected compute subnet actually exists.

### `floor`

`floor` rounds a number down:

```hcl
floor(2.7) # 2
floor(2)   # 2
```

This project compares a number with its floored value to test whether it is a
whole number:

```hcl
var.compute.instance_count == floor(var.compute.instance_count)
```

### `regex`

`regex` checks text against a pattern:

```hcl
can(regex("^ami-[0-9a-fA-F]+$", var.compute.ami_id))
```

In plain language, this pattern requires:

- `^` — the beginning of the text
- `ami-` — the literal prefix `ami-`
- `[0-9a-fA-F]+` — one or more hexadecimal characters
- `$` — the end of the text

An AMI ID such as `ami-0123abcdef` passes. Text such as `image-123` fails.

### `cidrnetmask`

`cidrnetmask` calculates a network mask from an IPv4 CIDR:

```hcl
cidrnetmask("10.0.0.0/16")
```

The project mainly uses it inside `can(...)`:

```hcl
condition = can(cidrnetmask(var.network.vpc_cidr_block))
```

If the CIDR is valid, the function succeeds and `can` returns `true`. If the
CIDR is malformed, `can` returns `false` instead of letting the function error
interrupt evaluation.

### `distinct`

`distinct` removes duplicate items from a list:

```hcl
condition = (
  length(distinct(subnet_cidrs)) == length(subnet_cidrs)
)
```

If removing duplicates does not change the length, every item was unique.

The actual project builds the list with a `for` expression:

```hcl
condition = (
  length(distinct([
    for subnet in values(var.network.public_subnets) : subnet.cidr_block
  ])) == length(var.network.public_subnets)
)
```

Read it from the inside out:

1. `values(...)` gets all subnet objects from the map.
2. `for subnet ... : subnet.cidr_block` extracts every CIDR.
3. `distinct(...)` removes duplicates.
4. The two lengths are compared.

## 7. `can` and `try`

Some Terraform functions produce an error for invalid input. Validation should
turn that problem into `false` and show a useful message.

### `can`

`can(expression)` returns:

- `true` if the expression can be evaluated successfully
- `false` if evaluating it produces an error

Example:

```hcl
condition = can(cidrnetmask(var.network.vpc_cidr_block))
```

This is useful when only success or failure matters.

### `try`

`try(first, fallback)` returns the first expression if it succeeds. If the
first expression errors, it returns the fallback:

```hcl
condition = try(cidrnetmask(cidr) != "0.0.0.0", false)
```

This checks that:

1. `cidr` is valid, and
2. it is not the completely open IPv4 network `0.0.0.0/0`.

If `cidrnetmask(cidr)` errors, `try` returns `false`, so validation fails
cleanly.

## 8. Validating Every Item in a Collection

`alltrue` returns `true` only when every item in a list is true:

```hcl
condition = alltrue([
  for cidr in var.application.allowed_cidr_blocks :
  can(cidrnetmask(cidr))
])
```

This expression:

1. Loops over every allowed CIDR.
2. checks whether each CIDR is valid,
3. creates a list of `true` and `false` results, and
4. requires every result to be `true`.

Example:

```text
["10.0.0.0/8", "192.168.1.0/24"]
        becomes
[true, true]
        becomes
true
```

If one CIDR is invalid:

```text
[true, false] becomes false
```

## 9. Optional Values and `null`

Some inputs are intentionally optional:

```hcl
private_ip_start = optional(number)
```

When it is omitted, its value is `null`. The validation must accept either
`null` or a valid number:

```hcl
condition = (
  var.compute.private_ip_start == null ||
  (
    var.compute.private_ip_start >= 4 &&
    var.compute.private_ip_start == floor(var.compute.private_ip_start)
  )
)
```

The `||` means **or**:

- The value may be `null`, or
- it must be a whole-number host offset of at least 4.

Terraform uses short-circuit evaluation here. When the value is `null`, the
first part is true, so the second part does not need to approve the value.

## 10. Cross-Variable Validation

Some rules depend on more than one input. For example, the selected compute
subnet key must exist in the network's subnet map:

```hcl
validation {
  condition = contains(
    keys(var.network.public_subnets),
    var.compute.subnet_key
  )
  error_message = "compute.subnet_key must match a key in network.public_subnets."
}
```

This checks a relationship, not just one value in isolation.

Another project rule confirms that the requested sequence of private IP
addresses fits inside the selected subnet. This expression is more advanced;
its main idea is:

```text
starting host number + number of instances
must fit inside the selected subnet
```

You do not need to memorize the full expression. Focus on recognizing that its
purpose is to reject an impossible configuration before AWS receives it.

## 11. Validation Versus Preconditions

This project also uses `precondition` blocks. They are related to validation,
but they run in a resource's context.

### Variable validation

Use validation to check configuration inputs:

```hcl
variable "instance_count" {
  validation {
    condition     = var.instance_count >= 1
    error_message = "At least one instance is required."
  }
}
```

### Resource precondition

Use a precondition when the rule depends on calculated or looked-up resource
information:

```hcl
resource "aws_instance" "web" {
  lifecycle {
    precondition {
      condition     = /* calculated private IP fits the real subnet */
      error_message = "The calculated private IP must fit in the subnet."
    }
  }
}
```

The compute module reads the real subnet with a data source. Its precondition
can therefore check the calculated private IP against that actual subnet.

In short:

```text
validation   -> Is the supplied configuration acceptable?
precondition -> Is it safe and valid to create this particular resource?
```

## 12. When Validation Runs

Terraform evaluates validation during operations that load and evaluate the
configuration, including:

```powershell
terraform validate
terraform plan
terraform apply
terraform test
```

`terraform validate` is the quickest general configuration check. A plan can
perform additional evaluation involving provider data and proposed resources.

## 13. What Validation Cannot Guarantee

Validation can catch predictable configuration mistakes, but it does not prove
that AWS will accept or successfully run everything.

For example:

- A CIDR may be syntactically valid but overlap another network.
- An AMI ID may have the correct format but not exist in the selected region.
- An allowed instance type string may not be offered in a particular AZ.
- A valid health-check path may still return HTTP 500 from the application.

These later checks belong to AWS API rules, Terraform planning, tests, or
runtime monitoring.

## 14. How to Read a Validation Block

Use this repeatable process:

1. Read the `error_message` first. It states the intended rule.
2. Identify the variable or attributes being checked.
3. Break the condition at each `&&` or `||`.
4. Translate each function into plain language.
5. Try one value that should pass and one that should fail.

Example:

```hcl
validation {
  condition = (
    var.application.listener_port >= 1 &&
    var.application.listener_port <= 65535 &&
    var.application.listener_port == floor(var.application.listener_port)
  )
  error_message = "The listener port must be a whole number from 1 to 65535."
}
```

Plain-language translation:

```text
The port must be at least 1
AND no more than 65535
AND a whole number.
```

## 15. Practice Exercises

Predict whether each value passes before checking the answers.

### Exercise 1: Instance count

Rule:

```hcl
value >= 1 && value == floor(value)
```

Values: `3`, `0`, `2.5`, `-1`

Answer: only `3` passes.

### Exercise 2: Architecture

Rule:

```hcl
contains(["x86_64", "arm64"], value)
```

Values: `"arm64"`, `"x86"`, `"x86_64"`

Answer: `"arm64"` and `"x86_64"` pass.

### Exercise 3: Optional private IP

Rule:

```hcl
value == null || (value >= 4 && value == floor(value))
```

Values: `null`, `4`, `3`, `7.5`

Answer: `null` and `4` pass.

### Exercise 4: Nonempty text

Rule:

```hcl
length(trimspace(value)) > 0
```

Values: `"eu-central-1"`, `""`, `"   "`

Answer: only `"eu-central-1"` passes.

## 16. Key Points to Remember

```text
A validation condition must evaluate to true.
The error message explains why a false condition is rejected.
Type checking asks what kind of value it is.
Validation asks whether that value is acceptable.
&& means and; || means or; ! means not.
can() converts an evaluation error into false.
try() provides a fallback when an expression errors.
alltrue() requires every check in a list to pass.
Validation catches mistakes early but cannot replace AWS or runtime checks.
```
