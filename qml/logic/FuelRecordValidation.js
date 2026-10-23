.pragma library

// Validate input and return the result, field errors, and numeric values to store.
function validate(draft) {
  draft = draft || {}
  const errors = {}
  const date = String(draft.date || "")
  const mileageText = numberText(draft.mileage)
  const litersText = numberText(draft.liters)
  const costText = numberText(draft.totalCost)
  const mileage = Number(mileageText)
  const liters = Number(litersText)
  const totalCost = Number(costText)

  if (!isValidDate(date))
    errors.date = qsTr("Choose a valid date on or before today.")
  if (!mileageText || !Number.isFinite(mileage) || mileage < 0)
    errors.mileage = qsTr("Enter an odometer reading of 0 or more.")
  if (!litersText || !Number.isFinite(liters) || liters <= 0)
    errors.liters = qsTr("Enter a fuel amount above 0.")
  if (!costText || !Number.isFinite(totalCost) || totalCost < 0)
    errors.totalCost = qsTr("Enter a cost of 0 or more.")

  return {
    valid: Object.keys(errors).length === 0,
    errors: errors,
    record: { date: date, mileage: mileage, liters: liters, totalCost: totalCost }
  }
}

// Trim whitespace and replace a decimal comma with a decimal point.
function numberText(value) {
  return String(value === undefined ? "" : value).trim().replace(",", ".")
}

// Check for a valid date in yyyy-MM-dd format that is not in the future.
function isValidDate(text) {
  const date = new Date(text + "T00:00:00")
  return Qt.formatDate(date, "yyyy-MM-dd") === text && date <= new Date()
}
