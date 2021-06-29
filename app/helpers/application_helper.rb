module ApplicationHelper
  def flash_class(level)
    { success: "alert alert-success alert-dismissible fade show",
      error: "alert alert-danger alert-dismissible fade show",
      alert: "alert alert-warning alert-dismissible fade show",
      notice: "alert alert-info alert-dismissible fade show" }.stringify_keys[level.to_s]
  end
end
