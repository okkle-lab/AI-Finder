import { Controller } from "@hotwired/stimulus"

const previousIndicatorByScope = new Map()

export default class extends Controller {
  static targets = ["indicator", "tab"]
  static values = { scope: String }

  connect() {
    this.frame = this.element.closest("turbo-frame")
    this.scopeKey = this.scopeValue || this.frame?.id || "default"
    this.storeIndicator = this.storeIndicator.bind(this)
    this.frame?.addEventListener("turbo:before-frame-render", this.storeIndicator)
    this.element.addEventListener("pointerdown", this.storeIndicator)
    this.positionIndicator()
    this.element.classList.add("model-score-tabs-ready")
  }

  disconnect() {
    this.frame?.removeEventListener("turbo:before-frame-render", this.storeIndicator)
    this.element.removeEventListener("pointerdown", this.storeIndicator)
  }

  positionIndicator() {
    if (!this.hasIndicatorTarget || !this.activeTab) return

    const next = this.metricsFor(this.activeTab)
    if (!next) return

    const previous = previousIndicatorByScope.get(this.scopeKey)

    this.applyMetrics(previous || next, false)
    this.indicatorTarget.getBoundingClientRect()

    requestAnimationFrame(() => {
      this.applyMetrics(next, !this.prefersReducedMotion && previous)
    })
  }

  storeIndicator() {
    if (!this.activeTab) return

    const metrics = this.metricsFor(this.activeTab)
    if (!metrics) return

    previousIndicatorByScope.set(this.scopeKey, metrics)
  }

  metricsFor(tab) {
    if (!this.element.isConnected || !tab.isConnected) return null

    const tabRect = tab.getBoundingClientRect()
    const containerRect = this.element.getBoundingClientRect()
    if (tabRect.width <= 0 || tabRect.height <= 0 || containerRect.width <= 0 || containerRect.height <= 0) return null

    return {
      left: tabRect.left - containerRect.left,
      top: tabRect.top - containerRect.top,
      width: tabRect.width,
      height: tabRect.height
    }
  }

  applyMetrics(metrics, animate) {
    this.indicatorTarget.style.transition = animate ? "" : "none"
    this.indicatorTarget.style.opacity = "1"
    this.indicatorTarget.style.width = `${metrics.width}px`
    this.indicatorTarget.style.height = `${metrics.height}px`
    this.indicatorTarget.style.transform = `translate(${metrics.left}px, ${metrics.top}px)`
  }

  get activeTab() {
    return this.tabTargets.find((tab) => tab.classList.contains("model-score-tab-active"))
  }

  get prefersReducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
