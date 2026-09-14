"""
ARTISAN CONNECT - Database Seeder
Populates the database with realistic indigenous and marginalized artisan profiles,
handcrafted product listings, smart AI tags, buyer inquiries, and notifications.
"""
import sys
import os

# Add backend directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.database import Base, engine, SessionLocal
from app.models.user import User, UserRole
from app.models.artisan import ArtisanProfile
from app.models.product import Product
from app.models.linkage import MarketLinkage, LinkageStatus
from app.models.notification import Notification, NotificationType
from app.services.auth_service import get_password_hash


def seed_database():
    print("Clearing and rebuilding database schema...")
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()

    try:
        print("Creating User Accounts...")
        # Common password for all seeded accounts: "password123"
        hashed_pw = get_password_hash("password123")

        # 1. Admin
        admin = User(
            email="admin@artisanconnect.org",
            hashed_password=hashed_pw,
            full_name="Artisan Connect Admin",
            phone="+1-800-555-0199",
            role=UserRole.ADMIN,
            is_active=True
        )
        db.add(admin)

        # 2. Artisans
        artisan_user_1 = User(
            email="ramlal.pottery@artisanconnect.org",
            hashed_password=hashed_pw,
            full_name="Ramlal Meena",
            phone="+91-98290-11223",
            role=UserRole.ARTISAN,
            is_active=True
        )
        artisan_user_2 = User(
            email="shanti.devi@artisanconnect.org",
            hashed_password=hashed_pw,
            full_name="Shanti Devi",
            phone="+91-94310-44556",
            role=UserRole.ARTISAN,
            is_active=True
        )
        artisan_user_3 = User(
            email="kavi.murugan@artisanconnect.org",
            hashed_password=hashed_pw,
            full_name="Kavi Murugan",
            phone="+91-94430-77889",
            role=UserRole.ARTISAN,
            is_active=True
        )
        artisan_user_4 = User(
            email="fatimah.begum@artisanconnect.org",
            hashed_password=hashed_pw,
            full_name="Fatimah Begum",
            phone="+91-98390-33445",
            role=UserRole.ARTISAN,
            is_active=True
        )
        db.add_all([artisan_user_1, artisan_user_2, artisan_user_3, artisan_user_4])

        # 3. Buyers
        buyer_user_1 = User(
            email="sarah.jenkins@ethicalliving.com",
            hashed_password=hashed_pw,
            full_name="Sarah Jenkins",
            phone="+1-512-555-8392",
            role=UserRole.BUYER,
            is_active=True
        )
        buyer_user_2 = User(
            email="marco.rossi@heritageimports.eu",
            hashed_password=hashed_pw,
            full_name="Marco Rossi",
            phone="+39-02-555-1234",
            role=UserRole.BUYER,
            is_active=True
        )
        db.add_all([buyer_user_1, buyer_user_2])
        db.commit()

        print("Creating Artisan Profiles...")
        profile_1 = ArtisanProfile(
            user_id=artisan_user_1.id,
            craft_type="Jaipur Blue Pottery & Terracotta",
            region="Kot Jewar, Jaipur, Rajasthan",
            community_cooperative="Jaipur Rural Traditional Potters Guild",
            heritage_story="Fifth-generation artisan working with non-clay quartz paste pottery, preserving Egyptian-Persian glazed techniques brought along the Silk Road.",
            bio="Specializes in low-temperature glazed decorative vases, tableware, and terracotta planter urns hand-painted with cobalt blue floral patterns.",
            years_of_experience=24,
            is_verified=True,
            avatar_url="https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80"
        )

        profile_2 = ArtisanProfile(
            user_id=artisan_user_2.id,
            craft_type="Handloom & Mithila Folk Textiles",
            region="Jitwarpur, Madhubani, Bihar",
            community_cooperative="Mithila Women Weavers Self-Help Collective",
            heritage_story="Leading a cooperative of 40 rural women who blend ancient Mithila ritual wall motifs with indigenous hand-spun Ahimsa silk and organic cotton.",
            bio="Dedicated to economic autonomy for village women through master-level handloom weaving, natural vegetable dyeing, and storytelling dupattas.",
            years_of_experience=19,
            is_verified=True,
            avatar_url="https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80"
        )

        profile_3 = ArtisanProfile(
            user_id=artisan_user_3.id,
            craft_type="Lost-Wax Bronze & Bell Metal",
            region="Swamimalai, Thanjavur, Tamil Nadu",
            community_cooperative="Hereditary Bronze Casters Guild",
            heritage_story="Practicing unbroken Chola-dynasty cire perdue (lost wax) casting method recognized globally with Geographical Indication (GI) status.",
            bio="Creates ceremonial lamps, ritual bell-metal homeware, and temple sculptures from recycled copper-tin alloy.",
            years_of_experience=28,
            is_verified=True,
            avatar_url="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80"
        )

        profile_4 = ArtisanProfile(
            user_id=artisan_user_4.id,
            craft_type="Chikankari & Hand Embroidery",
            region="Chowk, Lucknow, Uttar Pradesh",
            community_cooperative="Awadh Karigar Artisan Producer Co.",
            heritage_story="Mastering 32 authentic Chikankari needlework stitches passed down through maternal lineages in Old Lucknow.",
            bio="Crafts ethereal white-on-white shadow embroidery and jali latticework on sheer breathable organic muslin and fine cotton.",
            years_of_experience=15,
            is_verified=False,
            avatar_url="https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=200&q=80"
        )

        db.add_all([profile_1, profile_2, profile_3, profile_4])
        db.commit()

        print("Cataloging Handcrafted Products with AI Tags...")
        products = [
            Product(
                artisan_id=profile_1.id,
                title="Cobalt Blue Peacock Floral Urn",
                description="Authentic Jaipur blue pottery urn featuring quartz clay composition, copper oxide turquoise borders, and hand-painted cobalt peacock motifs. Fired in an artisanal wood-fuel kiln.",
                price=58.00,
                craft_type="Blue Pottery",
                materials="Quartz powder, recycled glass, natural gum, cobalt oxide",
                dimensions="18 x 18 x 30 cm",
                weight_grams=1250.0,
                production_time_days=6,
                stock_quantity=12,
                image_url="https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=600&q=80",
                ai_tags="blue-pottery, quartz, handmade, floral, jaipur, eco-friendly, decorative-vase",
                ai_suggested_price=64.00,
                is_available=True,
                views_count=84
            ),
            Product(
                artisan_id=profile_1.id,
                title="Terracotta Self-Watering Planter Pot",
                description="Porous natural river clay planter with saucer. Hand-turned on a foot-pedal wheel with natural burnished finish that keeps plant roots cool and aerated.",
                price=24.00,
                craft_type="Terracotta Pottery",
                materials="Pure alluvial river clay, red ochre slip",
                dimensions="15 x 15 x 16 cm",
                weight_grams=820.0,
                production_time_days=3,
                stock_quantity=25,
                image_url="https://images.unsplash.com/photo-1485955900006-10f4d324d411?auto=format&fit=crop&w=600&q=80",
                ai_tags="terracotta, clay, planter, gardening, breathable, organic, sustainable-living",
                ai_suggested_price=28.00,
                is_available=True,
                views_count=142
            ),
            Product(
                artisan_id=profile_2.id,
                title="Handwoven Ahimsa Silk Tree-of-Life Stole",
                description="Handloom woven peace silk stole adorned with hand-painted Mithila motifs using bamboo dip pens and organic pomegranate, turmeric, and indigo dyes.",
                price=85.00,
                craft_type="Handloom",
                materials="Ahimsa cruelty-free silk, natural vegetable dye",
                dimensions="200 x 60 cm",
                weight_grams=180.0,
                production_time_days=10,
                stock_quantity=6,
                image_url="https://images.unsplash.com/photo-1607083206869-4c7672e72a8a?auto=format&fit=crop&w=600&q=80",
                ai_tags="handloom, ahimsa-silk, natural-dye, tree-of-life, ethical-fashion, madhubani",
                ai_suggested_price=92.00,
                is_available=True,
                views_count=118
            ),
            Product(
                artisan_id=profile_2.id,
                title="Organic Khadi Cotton Table Runner Set",
                description="Four-piece dining set crafted from hand-spun and hand-woven 100% organic desi cotton. Natural unbleached ivory with hand-block printed indigo geometric borders.",
                price=42.00,
                craft_type="Handloom",
                materials="100% Organic Desi Khadi Cotton, Natural Indigo",
                dimensions="180 x 35 cm",
                weight_grams=350.0,
                production_time_days=5,
                stock_quantity=18,
                image_url="https://images.unsplash.com/photo-1528458876861-544fd1761a91?auto=format&fit=crop&w=600&q=80",
                ai_tags="khadi, organic-cotton, table-runner, handwoven, sustainable-dining, rustic",
                ai_suggested_price=46.00,
                is_available=True,
                views_count=65
            ),
            Product(
                artisan_id=profile_3.id,
                title="Traditional Lost-Wax Cast Deepam Oil Lamp",
                description="Hand-cast bell-metal ritual oil lamp with five wicks and swan finial. Made using the generational lost-wax technique in Swamimalai, polished with river sand.",
                price=95.00,
                craft_type="Metalcraft",
                materials="Bell metal, recycled copper, tin",
                dimensions="14 x 14 x 26 cm",
                weight_grams=1600.0,
                production_time_days=14,
                stock_quantity=5,
                image_url="https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=600&q=80",
                ai_tags="bronze, bell-metal, lost-wax, brass-decor, heritage-lamp, gi-tagged",
                ai_suggested_price=110.00,
                is_available=True,
                views_count=92
            ),
            Product(
                artisan_id=profile_4.id,
                title="Shadow-Work Chanderi Silk Kurta Fabric",
                description="Fine unstitched Chanderi silk tunic length featuring delicate Chikankari bakhia (shadow work), tepchi, and phanda stitches crafted over three weeks.",
                price=115.00,
                craft_type="Chikankari Embroidery",
                materials="Chanderi silk-cotton blend, fine cotton embroidery thread",
                dimensions="250 x 115 cm",
                weight_grams=210.0,
                production_time_days=18,
                stock_quantity=4,
                image_url="https://images.unsplash.com/photo-1558769132-cb1aea458c5e?auto=format&fit=crop&w=600&q=80",
                ai_tags="chikankari, hand-embroidery, chanderi-silk, slow-luxury, ethical-textiles",
                ai_suggested_price=125.00,
                is_available=True,
                views_count=77
            )
        ]
        db.add_all(products)
        db.commit()

        print("Generating Active Market Linkages & Inquiries...")
        linkages = [
            MarketLinkage(
                buyer_id=buyer_user_1.id,
                artisan_id=profile_1.id,
                product_id=products[0].id,
                status=LinkageStatus.ACCEPTED,
                quantity=15,
                proposed_unit_price=54.00,
                buyer_notes="We would like to stock 15 Cobalt Urns for our holiday boutique showcase in Austin, Texas. Need custom export packaging.",
                artisan_notes="Accepted! We can craft and securely crate 15 pieces in 3 weeks.",
                match_score=94.5,
                target_delivery_date="2026-11-15"
            ),
            MarketLinkage(
                buyer_id=buyer_user_1.id,
                artisan_id=profile_2.id,
                product_id=products[2].id,
                status=LinkageStatus.PENDING,
                quantity=20,
                proposed_unit_price=78.00,
                buyer_notes="Interested in bulk order of Ahimsa silk stoles for our ethical spring collection.",
                artisan_notes=None,
                match_score=91.0,
                target_delivery_date="2026-12-01"
            ),
            MarketLinkage(
                buyer_id=buyer_user_2.id,
                artisan_id=profile_3.id,
                product_id=products[4].id,
                status=LinkageStatus.COMPLETED,
                quantity=8,
                proposed_unit_price=95.00,
                buyer_notes="Custom architectural order for traditional hotel lounge project in Milan.",
                artisan_notes="Dispatched and received by client. Full payment processed.",
                match_score=96.0,
                target_delivery_date="2026-08-20"
            ),
            MarketLinkage(
                buyer_id=buyer_user_2.id,
                artisan_id=profile_1.id,
                product_id=products[1].id,
                status=LinkageStatus.PENDING,
                quantity=50,
                proposed_unit_price=22.00,
                buyer_notes="Seeking 50 terracotta planters for an eco-hospitality resort in Florence.",
                artisan_notes=None,
                match_score=88.5,
                target_delivery_date="2026-10-30"
            )
        ]
        db.add_all(linkages)
        db.commit()

        print("Creating Sample Notifications...")
        notifications = [
            Notification(
                user_id=artisan_user_1.id,
                title="New Buyer Inquiry (88% Match)",
                message="Marco Rossi submitted an inquiry for 50x 'Terracotta Self-Watering Planter Pot'.",
                notification_type=NotificationType.NEW_INQUIRY,
                reference_id=linkages[3].id,
                is_read=False
            ),
            Notification(
                user_id=artisan_user_1.id,
                title="Linkage Confirmed & In Progress",
                message="Order confirmed with Sarah Jenkins for 15x 'Cobalt Blue Peacock Floral Urn'. Target delivery: Nov 15.",
                notification_type=NotificationType.STATUS_CHANGED,
                reference_id=linkages[0].id,
                is_read=True
            ),
            Notification(
                user_id=artisan_user_2.id,
                title="New Buyer Inquiry (91% Match)",
                message="Sarah Jenkins inquired about 20x 'Handwoven Ahimsa Silk Tree-of-Life Stole'.",
                notification_type=NotificationType.NEW_INQUIRY,
                reference_id=linkages[1].id,
                is_read=False
            ),
            Notification(
                user_id=buyer_user_1.id,
                title="Artisan Accepted Your Inquiry!",
                message="Ramlal Meena accepted your inquiry for 15x 'Cobalt Blue Peacock Floral Urn'.",
                notification_type=NotificationType.STATUS_CHANGED,
                reference_id=linkages[0].id,
                is_read=True
            )
        ]
        db.add_all(notifications)
        db.commit()

        print("\n" + "=" * 60)
        print("SEEDING COMPLETE! Summary of Seeded Data:")
        print("=" * 60)
        print("Users Created:")
        print("  - Admin: admin@artisanconnect.org (Pass: password123)")
        print("  - Artisan 1: ramlal.pottery@artisanconnect.org (Pass: password123)")
        print("  - Artisan 2: shanti.devi@artisanconnect.org (Pass: password123)")
        print("  - Artisan 3: kavi.murugan@artisanconnect.org (Pass: password123)")
        print("  - Artisan 4: fatimah.begum@artisanconnect.org (Pass: password123)")
        print("  - Buyer 1: sarah.jenkins@ethicalliving.com (Pass: password123)")
        print("  - Buyer 2: marco.rossi@heritageimports.eu (Pass: password123)")
        print(f"Products Created: {len(products)}")
        print(f"Market Linkages Created: {len(linkages)}")
        print(f"Notifications Created: {len(notifications)}")
        print("=" * 60)

    except Exception as e:
        print(f"Error seeding database: {e}")
        db.rollback()
        raise e
    finally:
        db.close()


if __name__ == "__main__":
    seed_database()
