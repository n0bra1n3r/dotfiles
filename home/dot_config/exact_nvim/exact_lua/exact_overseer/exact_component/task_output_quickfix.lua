return {
  desc = "Write task output to quickfix",
  editable = false,
  serializable = false,
  constructor = function()
    return {
      on_init = function(self)
        self.task_id = nil
      end,
      on_exit = function(self, _, code)
        local is_ok, task_id = pcall(fn.update_task_output, code, self.task_id)
        if is_ok then
          self.task_id = task_id
        end
      end,
      on_output_lines = function(self, _, lines)
        local is_ok, task_id = pcall(fn.update_task_output, lines, self.task_id)
        if is_ok then
          self.task_id = task_id
        end
      end,
      on_start = function(self)
        local is_ok, task_id = pcall(fn.update_task_output, {})
        if is_ok then
          self.task_id = task_id
        end
      end,
    }
  end,
}
