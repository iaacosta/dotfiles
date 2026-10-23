---
name: real-rspec
description: RSpec tests - team conventions, strict structure patterns, performance. Use when writing or reviewing specs.
---

# RSpec (Team Conventions)

## Rule 1: Test structure — `let`, `before`, `it` have distinct roles

- **`let` / `let!`** — Variables referenced in `before`, expectations, or other `let` blocks.
- **`before`** — Setup not referenced again (side effects, unreferenced records, stubs).
- **`it`** — Expectations only. No setup.

### Bad
```ruby
let!(:slack_thread) { create(:slack_thread, slack_threadable: loan) }

it 'sends notification' do
  service = described_class.new(loan)
  service.process!
  expect(Slack::NotifyJob).to have_received(:set)
end
```

### Good
```ruby
let(:service) { described_class.new(loan) }

before { create(:slack_thread, slack_threadable: loan) }

it 'sends notification' do
  service.process!
  expect(Slack::NotifyJob).to have_received(:set)
end
```

**Note:** `freeze_time` wrapping and `expect { }.to change` are assertion idioms, not setup — they belong in `it`.

---

## Rule 2: One-liner syntax for single expectations

Use `{ }` instead of `do...end` and omit the description when a test is a single expectation.

```ruby
# Bad
it 'validates presence of name' do
  is_expected.to validate_presence_of(:name)
end

# Good
it { is_expected.to validate_presence_of(:name) }
it { is_expected.to belong_to(:group) }
it { expect(described_class.table_name).to eq('group_loans') }
```

Use `do...end` with a description when the test has multiple lines.

---

## Rule 3: Vary `let` across contexts for attribute/relation differences

When contexts differ by one attribute or relation, define a shared `let` and override per context.

### Bad
```ruby
context 'when active' do
  let(:loan) { create(:group_loan, status: 'active', amount: 10_000) }
  it { expect(loan).to be_eligible }
end

context 'when completed' do
  let(:loan) { create(:group_loan, status: 'completed', amount: 10_000) }
  it { expect(loan).not_to be_eligible }
end
```

### Good
```ruby
let(:loan) { create(:group_loan, status:, amount: 10_000) }

context 'when active' do
  let(:status) { 'active' }
  it { expect(loan).to be_eligible }
end

context 'when completed' do
  let(:status) { 'completed' }
  it { expect(loan).not_to be_eligible }
end
```

Skip this pattern when contexts differ in many attributes or need substantially different setup.

---

## Rule 4: Tests must actually verify the behavior

A test that passes regardless of implementation is useless. Always create records on **both sides** of a filter.

```ruby
# Would pass with GroupLoan.all — missing exclusion records
let!(:loan_1) { create(:group_loan, manager:) }
let!(:loan_2) { create(:group_loan, manager:) }

it { expect(manager.group_loans).to contain_exactly(loan_1, loan_2) }

# Fixed — add a record that should NOT be returned
before { create(:group_loan) }
```

**Key questions:** Would this pass if the method returned all records? An empty array? Does it verify both sides of the filter?

---

## Rule 5: Prefer `build` over `create`

Use `build` when the test doesn't need a persisted record. Use `create` for scopes, persisted associations, and on-save callbacks.

```ruby
let(:user) { build(:user) }
it { is_expected.not_to allow_value('invalid').for(:email) }
```

---

## Rule 6: Every change must have tests

Every file changed in `app/` must have a corresponding spec change. Flag missing coverage in PR reviews.

---

## Rule 7: Use `have_received`, not `should_receive`

Arrange-act-assert pattern. Stub in `before`, assert with `have_received` in `it`.

```ruby
before { allow(Slack::NotifyJob).to receive(:perform_later) }

it 'sends notification' do
  service.pass_application_to_review!
  expect(Slack::NotifyJob).to have_received(:perform_later).with(loan)
end
```

---

## Rule 8: Stub external dependencies

Unit tests should only test the class under test. Stub scopes/services that are tested elsewhere.

```ruby
let(:active_app) { create(:group_loan_application, aasm_state: 'in_kyc') }

before { allow(GroupLoanApplication).to receive(:in_the_process).and_return([active_app]) }

it 'processes only active applications' do
  described_class.process_all
  expect(SomeJob).to have_received(:perform_later).with(active_app)
end
```

---

## Rule 9: Test jobs for both `perform_later` and `perform_now`

Ensure jobs work when enqueued and when executed. Test enqueuing with `have_enqueued_job`, test execution by stubbing the external call and asserting `have_received`.

---

## Preferred matchers and helpers

- **`contain_exactly`** over `include` + `not_to include` — verifies exact contents in one assertion.
- **`have_attributes`** for multiple attribute checks — `expect(loan).to have_attributes(amount: 10_000, status: 'pending')`.
- **`receive_messages`** for multiple stubs on one object — `allow(client).to receive_messages(fetch_user: data, fetch_balance: balance)`.
- **`json_body`** instead of `JSON.parse(response.body)`.
- **`create_attachment_file('test.pdf')`** instead of `Rack::Test::UploadedFile.new(...)`.

---

## Additional patterns

### Time freezing
```ruby
it 'updates timestamp' do
  freeze_time do
    service.process!
    expect(loan.submitted_at).to eq(Time.current)
  end
end
```

### State changes
```ruby
it 'transitions states' do
  expect { perform }
    .to change { record.reload.aasm_state }.from('pending').to('submitted')
end
```
