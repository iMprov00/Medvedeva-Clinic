// Мобильное меню
document.addEventListener('DOMContentLoaded', function() {
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const nav = document.querySelector('.nav');
    const body = document.body;
    
    if (mobileMenuBtn && nav) {
        mobileMenuBtn.addEventListener('click', function() {
            nav.classList.toggle('active');
            mobileMenuBtn.classList.toggle('active');
            body.style.overflow = nav.classList.contains('active') ? 'hidden' : '';
        });
        
        // Закрытие меню при клике на ссылку
        const navLinks = document.querySelectorAll('.nav__link');
        navLinks.forEach(link => {
            link.addEventListener('click', function() {
                if (window.innerWidth <= 768) {
                    nav.classList.remove('active');
                    mobileMenuBtn.classList.remove('active');
                    body.style.overflow = '';
                }
            });
        });
        
        // Закрытие меню при клике вне его
        document.addEventListener('click', function(event) {
            if (window.innerWidth <= 768 && 
                nav.classList.contains('active') &&
                !nav.contains(event.target) &&
                !mobileMenuBtn.contains(event.target)) {
                nav.classList.remove('active');
                mobileMenuBtn.classList.remove('active');
                body.style.overflow = '';
            }
        });
    }
    
    // Плавная прокрутка для якорных ссылок
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            
            if (href !== '#' && href.startsWith('#')) {
                e.preventDefault();
                const targetElement = document.querySelector(href);
                
                if (targetElement) {
                    window.scrollTo({
                        top: targetElement.offsetTop - 100,
                        behavior: 'smooth'
                    });
                }
            }
        });
    });
    
    // Динамическое обновление шапки при скролле
    let lastScroll = 0;
    const header = document.querySelector('.header');
    
    if (header) {
        window.addEventListener('scroll', function() {
            const currentScroll = window.pageYOffset;
            
            if (currentScroll <= 0) {
                header.classList.remove('scroll-up');
                return;
            }
            
            if (currentScroll > lastScroll && !header.classList.contains('scroll-down')) {
                header.classList.remove('scroll-up');
                header.classList.add('scroll-down');
            } else if (currentScroll < lastScroll && header.classList.contains('scroll-down')) {
                header.classList.remove('scroll-down');
                header.classList.add('scroll-up');
            }
            
            lastScroll = currentScroll;
        });
    }
    
    // Добавляем анимацию появления элементов при скролле
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in');
            }
        });
    }, observerOptions);
    
    // Наблюдаем за карточками и другими элементами
    document.querySelectorAll('.doctor-card, .feature-card, .service-item, .doc-item').forEach(el => {
        observer.observe(el);
    });
    
    // Обработка форм
    const contactForm = document.getElementById('contact-form');
    if (contactForm) {
        contactForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Здесь должна быть отправка формы на сервер
            // Для демо просто покажем сообщение
            const submitBtn = this.querySelector('button[type="submit"]');
            const originalText = submitBtn.textContent;
            
            submitBtn.textContent = 'Отправка...';
            submitBtn.disabled = true;
            
            setTimeout(() => {
                alert('Сообщение отправлено! Мы свяжемся с вами в ближайшее время.');
                contactForm.reset();
                submitBtn.textContent = originalText;
                submitBtn.disabled = false;
            }, 1500);
        });
    }
    
    // Динамический поиск для врачей
    const doctorSearchInput = document.getElementById('doctor-search');
    const doctorSearchBtn = document.getElementById('search-doctor-btn');
    const specialtyFilter = document.getElementById('specialty-filter');
    
    if (doctorSearchInput || specialtyFilter) {
        function performDoctorSearch() {
            // Здесь будет AJAX запрос для поиска врачей
            console.log('Поиск врачей...');
        }
        
        if (doctorSearchBtn) {
            doctorSearchBtn.addEventListener('click', performDoctorSearch);
        }
        
        if (doctorSearchInput) {
            doctorSearchInput.addEventListener('keyup', function(event) {
                if (event.key === 'Enter') {
                    performDoctorSearch();
                }
            });
        }
        
        if (specialtyFilter) {
            specialtyFilter.addEventListener('change', performDoctorSearch);
        }
    }
    
    // Динамический поиск для услуг
    const serviceSearchInput = document.getElementById('service-search');
    const serviceSearchBtn = document.getElementById('search-service-btn');
    const categoryFilter = document.getElementById('category-filter');
    
    if (serviceSearchInput || categoryFilter) {
        function performServiceSearch() {
            // Здесь будет AJAX запрос для поиска услуг
            console.log('Поиск услуг...');
        }
        
        if (serviceSearchBtn) {
            serviceSearchBtn.addEventListener('click', performServiceSearch);
        }
        
        if (serviceSearchInput) {
            serviceSearchInput.addEventListener('keyup', function(event) {
                if (event.key === 'Enter') {
                    performServiceSearch();
                }
            });
        }
        
        if (categoryFilter) {
            categoryFilter.addEventListener('change', performServiceSearch);
        }
    }
    
    // Улучшение мобильного опыта
    if ('ontouchstart' in window) {
        document.body.classList.add('touch-device');
    }
});

// Добавляем обработку клавиши Escape для закрытия меню
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
        const nav = document.querySelector('.nav');
        
        if (nav && nav.classList.contains('active')) {
            nav.classList.remove('active');
            mobileMenuBtn.classList.remove('active');
            document.body.style.overflow = '';
        }
    }
});