// app/assets/javascripts/website_editor.js

document.addEventListener('DOMContentLoaded', function() {

    // Initialize editor functionality
    initializeWebsiteEditor();

    function initializeWebsiteEditor() {
        // Add edit button functionality
        setupEditButtons();
        // Setup modal handlers
        setupModalHandlers();
        // Setup form handlers
        setupFormHandlers();
        // Setup preview functionality
        setupPreviewHandlers();
    }

    function setupEditButtons() {
        document.querySelectorAll('.edit-component-btn').forEach(button => {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                const componentId = this.dataset.componentId;
                const themePageId = this.dataset.themePageId;
                openComponentEditor(componentId, themePageId);
            });
        });
    }

    function openComponentEditor(componentId, themePageId) {
        // Show loading state
        showLoadingModal();

        // Fetch component editor
        fetch(`/manage/website/components/${componentId}/edit?theme_page_id=${themePageId}`, {
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
            .then(response => response.json())
            .then(data => {
                hideLoadingModal();
                showComponentEditor(data.html);
                setupEditorFormHandlers(componentId, themePageId);
            })
            .catch(error => {
                hideLoadingModal();
                showError('Failed to load component editor');
                console.error('Error:', error);
            });
    }

    function setupModalHandlers() {
        // Close modal handlers
        document.addEventListener('click', function(e) {
            if (e.target.classList.contains('close-editor') ||
                e.target.closest('.close-editor')) {
                closeComponentEditor();
            }

            // Close modal when clicking outside
            if (e.target.classList.contains('component-editor-modal')) {
                closeComponentEditor();
            }
        });

        // Escape key to close modal
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeComponentEditor();
            }
        });
    }

    function setupFormHandlers() {
        // Handle component editor form submissions
        document.addEventListener('submit', function(e) {
            if (e.target.classList.contains('component-editor-form')) {
                e.preventDefault();
                handleComponentUpdate(e.target);
            }
        });
    }

    function setupPreviewHandlers() {
        // Handle preview button clicks
        document.addEventListener('click', function(e) {
            if (e.target.classList.contains('preview-btn')) {
                e.preventDefault();
                handlePreview(e.target);
            }
        });

        // Handle reset button clicks
        document.addEventListener('click', function(e) {
            if (e.target.classList.contains('reset-component-btn')) {
                e.preventDefault();
                handleComponentReset(e.target);
            }
        });

        // Real-time preview on input changes
        document.addEventListener('input', function(e) {
            if (e.target.closest('.component-editor-form')) {
                debounce(handleLivePreview, 500)(e.target.closest('.component-editor-form'));
            }
        });
    }

    function setupEditorFormHandlers(componentId, themePageId) {
        // Color field synchronization
        const colorInputs = document.querySelectorAll('input[type="color"]');
        colorInputs.forEach(colorInput => {
            const hexInput = document.querySelector(`input[data-field="${colorInput.dataset.field}"][data-type="hex"]`);

            if (hexInput) {
                colorInput.addEventListener('input', function() {
                    hexInput.value = this.value;
                });

                hexInput.addEventListener('input', function() {
                    if (isValidHexColor(this.value)) {
                        colorInput.value = this.value;
                    }
                });
            }
        });
    }

    function handleComponentUpdate(form) {
        const formData = new FormData(form);
        const url = form.action;

        // Get CSRF token from meta tag
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

        // Show saving state
        const submitButton = form.querySelector('button[type="submit"]');
        const originalText = submitButton.textContent;
        submitButton.textContent = 'Saving...';
        submitButton.disabled = true;

        fetch(url, {
            method: 'PATCH',
            body: formData,
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Accept': 'application/json',
                'X-CSRF-Token': csrfToken  // Add CSRF token to headers
            }
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Update the component in the preview
                    updateComponentInPreview(data.updated_html, form);
                    showSuccess(data.message);
                    closeComponentEditor();
                } else {
                    showError(data.error || 'Failed to update component');
                }
            })
            .catch(error => {
                showError('Network error occurred');
                console.error('Error:', error);
            })
            .finally(() => {
                submitButton.textContent = originalText;
                submitButton.disabled = false;
            });
    }

    function handlePreview(button) {
        const form = button.closest('form');
        const formData = new FormData(form);
        const componentId = form.action.match(/components\/(\d+)/)[1];
        const themePageId = new URLSearchParams(formData).get('theme_page_id') ||
            form.querySelector('input[name="theme_page_id"]')?.value;

        fetch(`/manage/website/components/${componentId}/preview?theme_page_id=${themePageId}`, {
            method: 'POST',
            body: formData,
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
            .then(response => response.json())
            .then(data => {
                // Show preview in modal or update component temporarily
                showPreviewOverlay(data.preview_html);
            })
            .catch(error => {
                showError('Failed to generate preview');
                console.error('Error:', error);
            });
    }

    function handleComponentReset(button) {
        if (!confirm('Are you sure you want to reset this component to its default values?')) {
            return;
        }

        const componentId = button.dataset.componentId;
        const themePageId = button.dataset.themePageId;

        fetch(`/manage/website/components/${componentId}/reset?theme_page_id=${themePageId}`, {
            method: 'DELETE',
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Update the component in preview
                    updateComponentInPreview(data.updated_html, button.closest('form'));
                    showSuccess(data.message);
                    closeComponentEditor();
                } else {
                    showError('Failed to reset component');
                }
            })
            .catch(error => {
                showError('Network error occurred');
                console.error('Error:', error);
            });
    }

    function handleLivePreview(form) {
        // Implement live preview functionality
        // This would update a preview pane in real-time as user types
    }

    // Utility functions
    function showComponentEditor(html) {
        // Remove any existing modals
        const existingModal = document.querySelector('.component-editor-modal');
        if (existingModal) {
            existingModal.remove();
        }

        // Add new modal to body
        document.body.insertAdjacentHTML('beforeend', html);

        // Focus first input
        const firstInput = document.querySelector('.component-editor-modal input, .component-editor-modal textarea');
        if (firstInput) {
            firstInput.focus();
        }
    }

    function closeComponentEditor() {
        const modal = document.querySelector('.component-editor-modal');
        if (modal) {
            modal.remove();
        }
    }

    function updateComponentInPreview(newHtml, form) {
        // Find the component in the preview and update it
        const componentId = form.action.match(/components\/(\d+)/)[1];
        const componentElement = document.querySelector(`[data-component-id="${componentId}"]`);

        if (componentElement) {
            // Update the inner content, preserving the editable wrapper
            const contentElement = componentElement.querySelector('.component-content') || componentElement;
            contentElement.innerHTML = newHtml;
        }
    }

    function showLoadingModal() {
        const loadingHtml = `
      <div class="component-editor-modal loading-modal">
        <div class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
          <div class="bg-white rounded-lg p-6">
            <div class="flex items-center">
              <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
              <span class="ml-3">Loading editor...</span>
            </div>
          </div>
        </div>
      </div>`;
        document.body.insertAdjacentHTML('beforeend', loadingHtml);
    }

    function hideLoadingModal() {
        const loadingModal = document.querySelector('.loading-modal');
        if (loadingModal) {
            loadingModal.remove();
        }
    }

    function showSuccess(message) {
        showNotification(message, 'success');
    }

    function showError(message) {
        showNotification(message, 'error');
    }

    function showNotification(message, type) {
        const notification = document.createElement('div');
        notification.className = `fixed top-4 right-4 z-50 p-4 rounded-md shadow-lg ${
            type === 'success' ? 'bg-green-50 text-green-800 border border-green-200' :
                'bg-red-50 text-red-800 border border-red-200'
        }`;
        notification.textContent = message;

        document.body.appendChild(notification);

        setTimeout(() => {
            notification.remove();
        }, 5000);
    }

    function showPreviewOverlay(html) {
        // Implementation for preview overlay
        const previewHtml = `
      <div class="preview-overlay fixed inset-0 bg-black bg-opacity-75 z-50 flex items-center justify-center">
        <div class="bg-white rounded-lg max-w-4xl max-h-[90vh] overflow-auto p-6">
          <div class="flex justify-between items-center mb-4">
            <h3 class="text-lg font-medium">Preview</h3>
            <button class="close-preview text-gray-400 hover:text-gray-600">
              <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          <div class="preview-content">${html}</div>
        </div>
      </div>`;

        document.body.insertAdjacentHTML('beforeend', previewHtml);

        // Close preview handler
        document.querySelector('.close-preview').addEventListener('click', function() {
            document.querySelector('.preview-overlay').remove();
        });
    }

    function isValidHexColor(hex) {
        return /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/.test(hex);
    }

    function debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
});