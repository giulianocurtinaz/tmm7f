
document.addEventListener("DOMContentLoaded", function () {
    const listContainer = document.querySelector('.listrecent');
    const loadingElement = document.getElementById('infinite-scroll-loading');
    
    // Check if we are on a page with a list of posts
    if (!listContainer || !loadingElement) return;

    // Helper to get next page URL from the DOM
    const getNextPageUrl = () => {
        const nextLink = document.querySelector('.pagination .next-page');
        return nextLink ? nextLink.href : null;
    };

    let nextPageUrl = getNextPageUrl();
    let isLoading = false;

    // If no next page initially, stop
    if (!nextPageUrl) return;

    // Intersection Observer Callback
    const observerCallback = (entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting && !isLoading && nextPageUrl) {
                loadNextPage();
            }
        });
    };

    // Observer Options
    const options = {
        root: null, // viewport
        rootMargin: '0px',
        threshold: 0.1
    };

    const observer = new IntersectionObserver(observerCallback, options);
    
    // sentinel element to trigger loading
    // We observe the last element of the list, or a dedicated sentinel
    let sentinel = document.createElement('div');
    sentinel.className = 'scroll-sentinel';
    listContainer.after(sentinel);
    observer.observe(sentinel);

    const loadNextPage = () => {
        isLoading = true;
        loadingElement.style.display = 'block';

        fetch(nextPageUrl)
            .then(response => {
                if (!response.ok) throw new Error('Network response was not ok');
                return response.text();
            })
            .then(html => {
                // Parse the response
                const parser = new DOMParser();
                const doc = parser.parseFromString(html, 'text/html');
                
                // Get new items
                const newItems = doc.querySelectorAll('.listrecent > *');
                
                // Append items
                newItems.forEach(item => {
                    listContainer.appendChild(item);
                });

                // Update next page URL
                const newNextLink = doc.querySelector('.pagination .next-page');
                nextPageUrl = newNextLink ? newNextLink.href : null;

                // Stop observing if no more pages
                if (!nextPageUrl) {
                    observer.unobserve(sentinel);
                    sentinel.remove();
                }

                isLoading = false;
                loadingElement.style.display = 'none';
            })
            .catch(error => {
                console.error('Error loading items:', error);
                isLoading = false;
                loadingElement.style.display = 'none';
            });
    };
});
