const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure upload directory exists
const uploadDir = process.env.UPLOAD_DIR || 'uploads';
const productImagesDir = path.join(uploadDir, 'products');
const profileImagesDir = path.join(uploadDir, 'profiles');
const reviewImagesDir = path.join(uploadDir, 'reviews');
const rfqAttachmentsDir = path.join(uploadDir, 'rfq');
const messageAttachmentsDir = path.join(uploadDir, 'messages');

[uploadDir, productImagesDir, profileImagesDir, reviewImagesDir, rfqAttachmentsDir, messageAttachmentsDir].forEach((dir) => {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
});

// Storage configuration
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        let folder = uploadDir;

        if (req.baseUrl.includes('/products')) {
            folder = productImagesDir;
        } else if (req.baseUrl.includes('/users') || req.baseUrl.includes('/auth')) {
            folder = profileImagesDir;
        } else if (req.baseUrl.includes('/reviews')) {
            folder = reviewImagesDir;
        } else if (req.baseUrl.includes('/rfq')) {
            folder = rfqAttachmentsDir;
        } else if (req.baseUrl.includes('/messages')) {
            folder = messageAttachmentsDir;
        }

        cb(null, folder);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    },
});

// File filter
const fileFilter = (req, file, cb) => {
    // Allowed file types
    const allowedImages = /jpeg|jpg|png|gif|webp/;
    const allowedDocs = /pdf|doc|docx|xls|xlsx|txt/;

    const extname = path.extname(file.originalname).toLowerCase();
    const isImage = allowedImages.test(extname.slice(1)) && file.mimetype.startsWith('image/');
    const isDocument = allowedDocs.test(extname.slice(1));

    // For RFQ and messages, allow both images and documents
    if (req.baseUrl.includes('/rfq') || req.baseUrl.includes('/messages')) {
        if (isImage || isDocument) {
            return cb(null, true);
        }
    } else {
        // For other routes, only allow images
        if (isImage) {
            return cb(null, true);
        }
    }

    cb(new Error('Invalid file type. Images: jpg, png, gif, webp. Documents: pdf, doc, docx, xls, xlsx, txt'));
};

// Multer configuration
const upload = multer({
    storage: storage,
    limits: {
        fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5 * 1024 * 1024, // 5MB default
    },
    fileFilter: fileFilter,
});

// Export different upload configurations
exports.uploadSingle = (fieldName) => upload.single(fieldName);
exports.uploadMultiple = (fieldName, maxCount = 5) => upload.array(fieldName, maxCount);
exports.uploadFields = (fields) => upload.fields(fields);

// Helper function to delete file
exports.deleteFile = (filePath) => {
    if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
    }
};
