// ✅ Import full Swiper bundle (includes all modules)
import Swiper from 'swiper/bundle';
import 'swiper/css/bundle';


function initializeSwiperCarousels() {
	const swiperContainers = document.querySelectorAll('.swiper-container');

	swiperContainers.forEach((swiperContainer) => {
		const speed = swiperContainer.getAttribute('data-speed') || 400;
		const spaceBetween = swiperContainer.getAttribute('data-space-between') || 20;
		const paginationEnabled = swiperContainer.getAttribute('data-pagination') === 'true';
		const navigationEnabled = swiperContainer.getAttribute('data-navigation') === 'true';
		const autoplayEnabled = swiperContainer.getAttribute('data-autoplay') === 'true';
		const autoplayDelay = swiperContainer.getAttribute('data-autoplay-delay') || 3000;
		const paginationType = swiperContainer.getAttribute('data-pagination-type') || 'bullets';
		const centerSlides = swiperContainer.getAttribute('data-center-slides') === 'true';
		const effect = swiperContainer.getAttribute('data-effect') || 'slide';
		const thumbsEnabled = swiperContainer.getAttribute('data-thumbs') === 'true';

		let breakpoints = {};
		const breakpointsData = swiperContainer.getAttribute('data-breakpoints');
		if (breakpointsData) {
			try {
				breakpoints = JSON.parse(breakpointsData);
			} catch (error) {
				console.error('Error parsing breakpoints data:', error);
			}
		}

		const swiperOptions = {
			speed: parseInt(speed),
			spaceBetween: parseInt(spaceBetween),
			breakpoints: breakpoints,
			slidesPerView: 'auto',
			effect: effect,
		};

		if (effect === 'fade') {
			swiperOptions.fadeEffect = { crossFade: true };
		}

		if (centerSlides) {
			swiperOptions.centeredSlides = true;
		}

		if (paginationEnabled) {
			const paginationEl = swiperContainer.querySelector('.swiper-pagination');
			if (paginationEl) {
				swiperOptions.pagination = {
					el: paginationEl,
					clickable: true,
					type: paginationType,
				};
			}
		}

		if (navigationEnabled) {
			const nextButton = swiperContainer.querySelector('.swiper-button-next');
			const prevButton = swiperContainer.querySelector('.swiper-button-prev');
			swiperOptions.navigation = {
				nextEl: nextButton,
				prevEl: prevButton,
			};
		}

		if (autoplayEnabled) {
			swiperOptions.autoplay = { delay: parseInt(autoplayDelay) };
		}

		let thumbsSwiper;
		if (thumbsEnabled) {
			const thumbsContainer = swiperContainer.nextElementSibling;
			if (thumbsContainer && thumbsContainer.classList.contains('swiper-thumbs')) {
				thumbsSwiper = new Swiper(thumbsContainer, {
					spaceBetween: 10,
					slidesPerView: 4,
					freeMode: true,
					watchSlidesProgress: true,
				});
				swiperOptions.thumbs = { swiper: thumbsSwiper };
			}
		}

		new Swiper(swiperContainer, swiperOptions);
	});
}

document.addEventListener('DOMContentLoaded', initializeSwiperCarousels);

const modalElement = document.getElementById('quickViewModal');
if (modalElement) {
	modalElement.addEventListener('shown.bs.modal', function () {
		initializeSwiperCarousels();
	});
}
