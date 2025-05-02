const multer = require('multer');
const fs = require('fs');
const path = require('path');

// Allowed file types
const fileFilter = (req, file, cb) => {
    console.log('Uploaded file mime type:', file.mimetype);
    const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp'];
    if (allowedTypes.includes(file.mimetype)) {
        cb(null, true);
    } else {
        cb(new Error('Only images (JPEG, PNG, JPG, WEBP) are allowed!'), false);
    }
};

// Function to create multer storage dynamically
const storage = (folder) => multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadPath = path.join(__dirname, `../uploads/${folder}`);
        if (!fs.existsSync(uploadPath)) {
            fs.mkdirSync(uploadPath, { recursive: true });
        }
        cb(null, uploadPath);
    },
    filename: (req, file, cb) => {
        cb(null, `${Date.now()}-${file.originalname}`);
    }
});

// Middleware for handling three specific images
const uploadProviderDocuments = multer({
    storage: storage('provider_documents'),
    fileFilter,
    limits: { fileSize: 10 * 1024 * 1024 } // 10MB max per image
}).fields([
    { name: 'front_image', maxCount: 1 },
    { name: 'back_image', maxCount: 1 },
    { name: 'diploma_image', maxCount: 1 }
]);

// Middleware for handling multiple provider images
const uploadProviderImages = multer({
    storage: storage('work_images'),
    fileFilter,
    limits: { fileSize: 10 * 1024 * 1024 } // 10MB max per image
}).array('work_images', 10); // Allow up to 10 images for a provider

// Middleware for handling three specific images
const uploadProfilePicture = multer({
    storage: storage('profile_pictures'),
    fileFilter,
    limits: { fileSize: 10 * 1024 * 1024 } // 10MB max per image
}).fields([
    { name: 'profile_image', maxCount: 1 },
]);

module.exports = { uploadProviderDocuments,uploadProfilePicture,uploadProviderImages };
